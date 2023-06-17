# syntaxHighlighterParallel

Syntax Highlighter for Python (Written in Elixir) Parallel Version

Authored by:

- Pablo Banzo Prida
- Gabriel Rodriguez de los Reyes

## About

This repository contains an Elixir program that reads a directory of Python files, highlights their syntax, and outputs an HTML file for each file in the input directory with the highlighted syntax. The syntax highlighter recognizes Python language constructs such as strings, comments, keywords, numbers, operators, booleans, functions, parentheses, methods, and decorators.

## Prerequisites

- Elixir installed on your machine.

## Elixir Installation

Please refer to the official [Elixir Installation Guide](https://elixir-lang.org/install.html) to set up Elixir on your machine.

## Installation and Usage

1. Clone this repository to your local machine.

```bash
git clone https://github.com/pridapablo/syntaxHighlighterParallel.git
```

2. Navigate to the repository folder.

```bash
cd syntaxHighlighterParallel
```

3. Run the highlighter module.

```bash
iex ParalelPrettier.exs
```

4. To highlight a python file, use the following Elixir command in your terminal (while in the iex session):

```elixir
SyntaxParallel.highlight("<directory-of-python-files>")
```

Replace <directory-of-python-files> with the name of the Python file directory you want to analyze. For example:

```elixir
SyntaxParallel.highlight("PythonFiles")
```

The current repository contains three Python files that you can use to test the syntax highlighter (all three files are in the PythonFiles/ directory)

- example1_OOP.py
- example2_Procedural.py
- example3_Functional.py

4. The program will create an HTML file in the root directory with the same base name as your Python file. For example, if your Python file was named example.py, the output file will be example.py.html.

5. Open the generated HTML file in your web browser to see the highlighted Python code.

## One Pager Analysis

There is a OnePager.md file at the root of this repository. It contains:

- Reflections on the proposed solution, the implemented algorithms, and the execution time of these algorithms.

- A comparison of the execution time of the parallel and sequential versions of the syntax highlighter.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
