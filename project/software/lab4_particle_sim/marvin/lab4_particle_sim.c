// Memory Configuration
#define IROM_BASE 0x00000000
#define DMEM_BASE 0x00002000
#define DMEM_SIZE 0x400
#define MMIO_BASE (DMEM_BASE + DMEM_SIZE)
#define STACK_INIT MMIO_BASE

// Memory-mapped peripheral register offsets
#define LED_OFF 0x00            // WO
#define DIP_OFF 0x04            // RO
#define PB_OFF 0x08             // RO
#define UART_OFF 0x0C           // RW
#define UART_RX_VALID_OFF 0x10  // RO, status bit
#define UART_RX_READY_OFF 0x14  // RO, status bit
#define SEVENSEG_OFF 0x18       // WO
#define CYCLECOUNT_OFF 0x1C     // WO
#define OLED_COL_ADDR_OFF 0x20  // WO
#define OLED_ROW_ADDR_OFF 0x24  // WO
#define OLED_DATA_ADDR_OFF 0x28 // WO
#define OLED_CTRL_ADDR_OFF 0x2C // WO
#define ACCEL_DATA_OFF 0x30     // RO
#define ACCEL_DREADY_OFF 0x34   // RO, status bit

#define SCREEN_WIDTH 96
#define SCREEN_HEIGHT 64
#define NUM_PARTICLES 4
#define FIXED_POINT_SHIFT 4

/* Particle structure creates opportunities for pipeline optimization:
 * - Multiple fields create load-use hazards when accessing struct members
 * - Updates to position/velocity show benefits of data forwarding
 * - Array of particles creates regular memory access patterns for branch prediction
 */
typedef struct
{
    int x, y;   // Position (fixed point)
    int dx, dy; // Velocity (fixed point)
} Particle;


void init_particles(Particle particles[NUM_PARTICLES]);
void output_performance(unsigned int cycles);
void update_particles(Particle particles[NUM_PARTICLES]);
void draw_particles(Particle particles[NUM_PARTICLES]);
volatile unsigned int *const CYCLECOUNT_ADDR = (unsigned int *)(MMIO_BASE + CYCLECOUNT_OFF);

/* Main function - structured to measure optimization benefits:
 * - Separates computation from I/O
 * - Uses cycle counter to measure performance
 * - Regular performance reporting shows improvement
 */
int main()
{
    // Initialize stack pointer
    asm volatile("li sp, %0" : : "i"(STACK_INIT)); // inline assembly to init sp. Registers cant be accessed explicitly in pure C

    Particle particles[NUM_PARTICLES];
    init_particles(particles); // Initialize with some pattern
    unsigned int frame_count = 0;
    volatile unsigned int* SEVENSEG_ADDR = (unsigned int*) (MMIO_BASE+SEVENSEG_OFF);

    while (1)
    {
        // Measure computation time separately from I/O
        unsigned int start_cycles = *CYCLECOUNT_ADDR;
        update_particles(particles); // Compute-intensive portion
        unsigned int compute_cycles = *CYCLECOUNT_ADDR - start_cycles;

        // I/O portion doesn't affect computation measurements
        draw_particles(particles);

        // Performance monitoring
        frame_count++;
        *SEVENSEG_ADDR = frame_count; 
        if ((frame_count & 0xF) == 0)
        {                                       // Every 16 frames
            output_performance(compute_cycles); // Report performance
        }
    }

    return 0;
}

/* Initialize particles in a deterministic pattern
 * Using fixed patterns helps when comparing performance
 * across different pipeline configurations
 */
void init_particles(Particle particles[NUM_PARTICLES])
{
    for (int i = 0; i < NUM_PARTICLES; i++)
    {
        // Spread particles across screen width
        particles[i].x = (i * SCREEN_WIDTH / NUM_PARTICLES) << FIXED_POINT_SHIFT;
        // Center vertically
        particles[i].y = (SCREEN_HEIGHT / 2) << FIXED_POINT_SHIFT;

        // Alternate velocity directions based on index
        particles[i].dx = ((i & 1) ? 1 : -1) << (FIXED_POINT_SHIFT - 2);
        particles[i].dy = ((i & 2) ? 1 : -1) << (FIXED_POINT_SHIFT - 2);
    }
}

/* Output performance metrics via UART
 * Shows the impact of pipeline optimizations through cycle counts
 */
void output_performance(unsigned int cycles)
{
    volatile unsigned int *const UART_ADDR = (unsigned int *)(MMIO_BASE + UART_OFF);
    volatile unsigned int *const UART_TX_READY_ADDR = (unsigned int *)(MMIO_BASE + UART_RX_READY_OFF);

    // Output cycle count byte by byte
    for (int i = 24; i >= 0; i -= 8)
    {
        while (!(*UART_TX_READY_ADDR))
            ; // Wait for UART ready
        *UART_ADDR = (cycles >> i) & 0xFF;
    }
}

/* Main particle update function - demonstrates both hazard resolution and branch prediction
 * This function contains the most intensive computation and shows the biggest
 * benefits from pipeline optimizations
 */
void update_particles(Particle particles[NUM_PARTICLES])
{
    for (int i = 0; i < NUM_PARTICLES; i++)
    {
        /* Position Update Section
         * Demonstrates RAW (Read After Write) hazards:
         * 1. Load current position and velocity
         * 2. Perform addition
         * 3. Store result back
         *
         * Without forwarding: ~3 cycles per update (load → add → store)
         * With forwarding: ~1-2 cycles (forwarding from ALU/MEM stage)
         */
        particles[i].x += particles[i].dx; // RAW hazard
        particles[i].y += particles[i].dy; // RAW hazard

        /* Boundary Checking Section
         * Demonstrates branch prediction benefits:
         * - Regular pattern of branches (particles bounce predictably)
         * - Branch predictor can learn screen boundary patterns
         * - Multiple branches in sequence test predictor capability
         */
        if ((particles[i].x >> FIXED_POINT_SHIFT) >= SCREEN_WIDTH)
        {
            particles[i].x = (SCREEN_WIDTH - 1) << FIXED_POINT_SHIFT;
            particles[i].dx = -particles[i].dx; // Velocity reversal - another RAW hazard
        }
        if ((particles[i].x >> FIXED_POINT_SHIFT) < 0)
        {
            particles[i].x = 0;
            particles[i].dx = -particles[i].dx;
        }
        if ((particles[i].y >> FIXED_POINT_SHIFT) >= SCREEN_HEIGHT)
        {
            particles[i].y = (SCREEN_HEIGHT - 1) << FIXED_POINT_SHIFT;
            particles[i].dy = -particles[i].dy;
        }
        if ((particles[i].y >> FIXED_POINT_SHIFT) < 0)
        {
            particles[i].y = 0;
            particles[i].dy = -particles[i].dy;
        }

        /* Particle Interaction Section
         * This section heavily tests both optimizations:
         *
         * Hazard Resolution Benefits:
         * - Multiple dependent loads and stores
         * - Complex data dependencies in collision calculations
         * - Register value reuse in velocity swaps
         *
         * Branch Prediction Benefits:
         * - Nested loops with regular patterns
         * - Multiple conditional checks for collisions
         * - Predictable patterns of particle interactions
         */
        for (int j = i + 1; j < NUM_PARTICLES; j++)
        {
            // Distance calculation - multiple data dependencies
            int dx = particles[i].x - particles[j].x;
            int dy = particles[i].y - particles[j].y;

            // Collision detection - branch prediction opportunity
            if (dx < (2 << FIXED_POINT_SHIFT) &&
                dx > -(2 << FIXED_POINT_SHIFT) &&
                dy < (2 << FIXED_POINT_SHIFT) &&
                dy > -(2 << FIXED_POINT_SHIFT))
            {

                /* Velocity swap - multiple RAW hazards:
                 * 1. Load original velocities
                 * 2. Store to temporary
                 * 3. Copy between particles
                 * Without forwarding: Many stall cycles
                 * With forwarding: Significantly fewer stalls
                 */
                int tdx = particles[i].dx;
                int tdy = particles[i].dy;
                particles[i].dx = particles[j].dx;
                particles[i].dy = particles[j].dy;
                particles[j].dx = tdx;
                particles[j].dy = tdy;
            }
        }
    }
}

/* Drawing function - even display code benefits from optimizations:
 * - Regular nested loops benefit from branch prediction
 * - Coordinate calculations show data forwarding benefits
 * - Screen boundary checks create predictable branch patterns
 */
void draw_particles(Particle particles[NUM_PARTICLES])
{
    volatile unsigned int *const OLED_ROW_ADDR = (unsigned int *)(MMIO_BASE + OLED_ROW_ADDR_OFF);
    volatile unsigned int *const OLED_COL_ADDR = (unsigned int *)(MMIO_BASE + OLED_COL_ADDR_OFF);
    volatile unsigned int *const OLED_DATA_ADDR = (unsigned int *)(MMIO_BASE + OLED_DATA_ADDR_OFF);
    volatile unsigned int *const OLED_CTRL_ADDR = (unsigned int *)(MMIO_BASE + OLED_CTRL_ADDR_OFF);

    /* Clear screen using row variation mode for efficiency */
    // - Upper nibble (0): 8-bit color mode
    // - Lower nibble (2): vary_ROW_mode
    *OLED_CTRL_ADDR = 0x02;
    *OLED_DATA_ADDR = 0x00; // Black in 8-bit format

    for (int y = 0; y < SCREEN_HEIGHT; y++)
    {
        *OLED_ROW_ADDR = y;
    }

    /* Draw particles - mix of computation and I/O */
    // - Upper nibble (0): 8-bit color mode
    // - Lower nibble (0): vary_pixel_data_mode
    *OLED_CTRL_ADDR = 0x00;
    *OLED_DATA_ADDR = 0xFF; // White in 8-bit format
    for (int i = 0; i < NUM_PARTICLES; i++)
    {
        // Coordinate calculation - benefits from forwarding
        int x = particles[i].x >> FIXED_POINT_SHIFT;
        int y = particles[i].y >> FIXED_POINT_SHIFT;

        // Boundary check - predictable branch pattern
        if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT)
        {
            *OLED_ROW_ADDR = y;
            *OLED_COL_ADDR = x;
        }
    }
}