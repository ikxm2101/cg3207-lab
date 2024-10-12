## Programme Flow
1. Prints welcome message.
2. User enter X1 coordinate, uses '\r' to end input
    - Programme will read the input character by character
    - To get the value of the digit, we will subtract the ASCII value of '0' (assume user will only input 0 - 9, no checking)
    - Accumulated value is multiplied by 10
    - New input digit will be added to the accumulated value
3. User enter Y1 coordinate, uses '\r' to end input
4. User enter X2 coordinate, uses '\r' to end input
5. User enter Y2 coordinate, uses '\r' to end input
6. If X1 and X2 is the same, print invalid message and go back to step 1
7. Do X1 - X2, if negative, set flag.
8. If Y1 and Y2 is the same, print horizontal line equation.
9. Do Y1 - Y2, if negative, set flag.
10. If flag are the same, gradient is positive. Otherwise negative.
11. If X2 > X1, swap X1 and X2 such that its delta is positive
12. If Y2 > Y1, swap Y1 and Y2 such that its delta is positive
13. Calculate the X and Y delta, and get the gradient.
14. Calculate gradient * X1 and if gradient sign is negative, negate the result.
15. Calculate Y-intercept = Y1 - gradient * X1
16. Print Equation 
    - if X1==X2, print "Gradient is infinity"
    - if Y1==Y2, print "Equation: Y = [-]\<Y1\>"
    - otherwise, print "Equation: Y = [-]\<m\>X[+/-]\<intercept\>"
