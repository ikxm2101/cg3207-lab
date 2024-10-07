## Programme Flow
1. Wait for user to enter 'S' to start the Programme
2. User enter X1 coordinate, uses '\r' to end input
    - Programme will read the input character by character
    - To get the value of the digit, we will subtract the ASCII value of '0' (if value is negative or >9 we will substitute the value with '0')
    - Accumulated value is multiplied by 10
    - New input digit will be added to the accumulated value
3. User enter Y1 coordinate, uses '\r' to end input
4. User enter X2 coordinate, uses '\r' to end input
5. User enter Y2 coordinate, uses '\r' to end input
6. Find out if X1 or X2 is larger
    - Subtract X2 from X1 (X1 - X2)
    - `sra` 31 bits to see if the value is negative
    - If value is negative X2 > X1
    - If values are the same then return "Invalid, cos gradient will be infinite"
7. Find out if Y1 or Y2 is larger
    - If values are the same return 0
8. If both X1 and Y1 are the larger values or both X2 and Y2 are the larger values, then the gradient is positive
9.  If X1 and Y2 are the larger values or X2 and Y1 are the larger values, the gradient is negative
10. Record down if gradient is positive or negative
11. We will calculate the "gradient" by subtracting the smaller number from the larger number. (This is done as we cant do signed division)
12. If gradient is supposed to be negative, negate the calculated gradient (by subtracting it from 0)
13. To get y-intercept, we will take (Y1 - X1 * Gradient)
14. Print out the equation of the graph in the format of: y = mx + c
    - If m is negative a '-' must be printed
    - If c is negative a '-' must be printed, else '+' will be printed