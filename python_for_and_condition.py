
# short style
liste = [expression for value in collection if condition]

# long style
liste = []
for value in collection:
    if condition:
        vals.append(expression)

# example

liste = [x * x for x in range(10) if not x % 2]
liste
[0, 4, 16, 36, 64]
