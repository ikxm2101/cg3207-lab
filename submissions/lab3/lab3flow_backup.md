## Programme Flow
1. Prints welcome message.
2. User enter value of X, uses '\r' to end input
    - Programme will read the input character by character
    - To get the value of the digit, we will subtract the ASCII value of '0' (assume user will only input 0 - 9, no checking)
    - Accumulated value is multiplied by 10
    - New input digit will be added to the accumulated value
3. User enter value of Y, uses '\r' to end input
4. The value of `X * Y` and `X / Y` are calculated
5. If `DIPS[0] == 1` the result `X / Y` will be shown on the seven segment display
6. If `DIPS[0] == 0` the result `X * Y` will be shown on the seven segment display

  
  ### Variables
| Name | Description                | Initial Value |
| ---- | -------------------------- | ------------- |
| s2   | Value of '0' in ASCII      | 48            |
| s3   | Value of 10 for multiplier | 10            |
| s4   | Value of '\r'              | 13            |
| s5   | SIGN_MASK                  | 0x80000000    |
| s6   | LSB_MASK                   | 0XFF          |
| s7   | DIPS                       | 0x00002404    |
| s8   | CONSOLE_OUT_ready          | 0x00002414    |
| s9   | CONSOLE_IN_valid           | 0x00002410    |
| s10  | CONSOLE                    | 0x0000240C    |
| s11  | SEVENSEG                   | 0x00002418    |
| a0   | Value of X                 | 0             |
| a1   | Value of Y                 | 0             |
| a2   | Value of X * Y             | 0             |
| a3   | Value of X / Y             | 0             |