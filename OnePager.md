# Parallel and Sequential Programming (Lexer)

### By:

- **Gabriel Rodriguez De Los Reyes**
- **Pablo Banzo Prida**

The purpose of this activity is to assess the performance of a syntax highlighting program implemented in Elixir, which can read code files in a specified directory and generate HTML files with the code syntax highlighted.

This Elixir application reads all the files in a provided directory, processes them concurrently using Elixir's Task.async_stream, applies syntax highlighting rules line by line and then writes the highlighted code to an HTML file. The process is wrapped within the highlight/1 function of the Syntaxhighlighter module.

To verify the functionality of the program, we provided it with a directory of python files named "PythonFiles". Each file was read, processed, and an HTML file was generated successfully.

The function execution is timed using the Timing.time_execution/1 function which is defined in the Timing module.

# Time analysis

The following table shows the results of the execution of the program with the
two different versions of the function. Considering that the computer may be
running other processes at the same time, we run the program 3 times and take
the average of the results.

We ran the following script in a for loop for each function version:

## **Parallel**

```elixir
iex ParalelPrettier.exs
```

```elixir
Timing.time_execution(fn ->
  Syntax.highlight("PythonFiles/example1_OOP.py")
  Syntax.highlight("PythonFiles/example2_Procedural.py")
  Syntax.highlight("PythonFiles/example3_Functional.py")
end)
```

### **Parallel Results**

```
Time in seconds: 0.160975
Time in seconds: 0.157837
Time in seconds: 0.157477
```

## **Sequential**

```elixir
iex Prettier.exs
```

```elixir
Timing.time_execution(fn ->
  Syntaxhighlighter.highlight("PythonFiles")
end)
```

### **Sequential Results**

```
Time in seconds: 1.586709
Time in seconds: 1.480552
Time in seconds: 1.578452
```

## **Analysis**

Given the results, we can see that the parallel version of the function is
faster than the sequential version in all runs. It is also worth noting that the
computer running the tests has 8 cores (MacBook Air M2 512GB SSD 24GB RAM), so
the parallel version of the function is able to take advantage of all the cores.

# Speedup analysis

$$ \begin{equation} S_p = \frac{T_s}{T_p} \end{equation} $$

Where:

- $S_p$ is the speedup
- $T_s$ is the time of the sequential version of the function
- $T_p$ is the time of the parallel version of the function

## **Speedup**

$$
\begin{equation} S_p = \frac{1.548571}{0.158763} = 9.7539792017
\end{equation}
$$

## Conclusion

The speedup of the parallel version of the function is 9.7539792017, which means
that the parallel version of the function is almost 10 times faster than the sequential
version of the function.

# Ethical Implications

The most important ethical implication of this activity is the fact that more efficient programs can be developed using parallel programming. This means that the same amount of work can be done in less time, which can result in more energy-efficient programs. This is important because the energy consumption of computers is a big problem nowadays, and it is expected to increase in the future. Therefore, parallel programming can help reduce the energy consumption of computers.
