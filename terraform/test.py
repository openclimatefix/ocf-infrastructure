"""
Quick interview python test

This code is badly written and the aim is to
fix, make it better, say whats wrong with it.

This can work in person, or it can be sent to someone

"""

"""
The function
1. adds up the square numbers between the first two arguments
2. then adds all the values in the initial_series

sum(2, 3, initial_series = [7,9])
= 2*2 + 3*3 + 7 + 9 = 4 + 9 + 7 + 9 = 29
"""

"""
Answers / Hints
1. Bad function name
2. Shouldn't use list in function definition
3. while loop doesnt include end
4. while loop adds start*start, it should use 'number'
5. Perhaps for loop is better than while loop?
6. Can shorten to number =+ 1
7. Bad variable names, should be same as python default, and shouldn't be the same as function name
8. Dont need the for loop, can just use 'sum'
9. Doesnt return anything, should rent

1. What happens if start and end was very big? Could use 'numpy' instead. Why would you use 'numpy'?
2. How can you make the code more easy to read? Add comments, and function description, typing
3. What about unittest tests?
"""


def sum(start, e, initial_series=[]):

    number = start
    while start < e:
        initial_series.append(start*start)
        number = number + 1

    sum = 0
    for i in initial_series:
        sum = sum + i
