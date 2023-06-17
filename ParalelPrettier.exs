defmodule SyntaxParallel do
  def highlight(directory_path) do
    # get current working directory
    {:ok, path} = :file.get_cwd()
    IO.puts(path)

    read_files_from_folder(directory_path)
    # run highlight_file in parallel
    |> Task.async_stream(&highlight_file/1)
    |> Enum.each(fn
      # result is the file path
      {:ok, result} -> IO.puts("File processed successfully")
      # error is the error reason
      {:error, error} -> IO.puts("Error processing file")
      # other is unexpected result
      other -> IO.puts("Unexpected result")
    end)
  end

  # read all files from a folder
  defp read_files_from_folder(directory_path) do
    # list all files from the directory
    File.ls!(directory_path)
    |> Enum.map(fn file -> Path.join(directory_path, file) end)
  end

  # split the file into lines to process them
  defp highlight_file(file) do
    # run the task in parallel
    Task.async(fn ->
      # get the full path of the file
      expanded_path = Path.expand(file)

      IO.puts("Reading file: #{expanded_path}")

      # read the file
      case File.read(expanded_path) do
        {:error, _reason} ->
          # if the file can't be read, return
          IO.puts("Failed to read file: #{expanded_path}")
          {:error, :read_failure}

        {:ok, text} ->
          highlighted_text =
            text
            # split the file into lines
            |> String.split(~r/\n/, trim: false)
            # run helperFun in parallel
            |> Enum.map(&helperFun/1)
            # join the lines back together
            |> Enum.join("\n")

          # build the html with the highlighted text
          html_content = build_html_content(highlighted_text)

          # saves the html file
          case File.write("#{Path.basename(expanded_path)}.html", html_content) do
            :ok -> file
            {:error, reason} -> {:error, reason}
          end
      end
    end)
  end

  # DFA detect the type of the character and adds the html <span> tag that corresponds to the type of the character
  # the paramterers are: charDetector(List of characters, string to return, status of the previous character, accumulator of characters)
  defp charDetector([head | tail], list, status, val) do
    # if the list is empty, return the list
    if tail == [] do
      list
    else
      case head do
        # if the status is string wait fot the next " or '
        a when status == "string" ->
          if status == "string" && a in ["\"", "\'"] do
            charDetector(
              tail,
              list <> "<span class=\"string\">" <> val <> head <> "</span>",
              "",
              ""
            )
          else
            charDetector(tail, list, "string", val <> head)
          end

        # if the status is comment wait fot the next •
        a when status == "comment" ->
          if head == "•" do
            charDetector(
              tail,
              list <> "<span class=\"comment\">" <> val <> "</span>",
              "",
              ""
            )
          else
            charDetector(tail, list, "comment", val <> head)
          end

        # if the status is method wait fot the next space, ( or .
        a when status == "method" ->
          if a in [" ", "(", "."] do
            charDetector(
              [head | tail],
              list <> "<span class=\"text\">" <> val <> "</span>",
              "",
              ""
            )
          else
            charDetector(tail, list, "method", val <> head)
          end

        # if the status is decorator wait fot the next space
        a when status == "decorator" ->
          if a == " " do
            charDetector(
              tail,
              list <> "<span class=\"decorator\">" <> val <> "</span>",
              "",
              ""
            )
          else
            charDetector(tail, list, "decorator", val <> head)
          end

        # if the char is " or ' change the status to string
        a when a in ["\"", "\'"] ->
          charDetector(tail, list, "string", val <> head)

        "(" ->
          # if the status is text and the ( to the list
          if status == "text" do
            charDetector(
              tail,
              list <>
                "<span class=\"function\">" <>
                val <>
                "</span>" <>
                "<span class=\"parenthesis\">" <> head <> "</span>",
              "",
              ""
            )
          else
            # if the status is not text add only the (
            charDetector(
              tail,
              list <> "<span class=\"parenthesis\">" <> head <> "</span>",
              "",
              ""
            )
          end

        "#" ->
          # if the char is # change the status to comment
          charDetector(tail, list, "comment", val <> head)

        # if the char is a number
        a when a in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] ->
          charDetector(tail, list <> "<span class=\"number\">" <> head <> "</span>", "", "")

        # if the char is a parenthesis
        a when a in ["{", "}", "[", "]", ")"] ->
          # if the status is text and the parenthesis to the list
          # if the status is not text add only the parenthesis
          if status == "text" do
            charDetector(
              tail,
              list <>
                "<span class=\"text\">" <>
                val <>
                "</span>" <>
                "<span class=\"parenthesis\">" <> head <> "</span>",
              "",
              ""
            )
          else
            charDetector(
              tail,
              list <> "<span class=\"parenthesis\">" <> head <> "</span>",
              "",
              ""
            )
          end

        # if the char is an operator
        a when a in [":", ",", ";", "+", "-", "*", "/", "%", "^"] ->
          # if the status is text and the operator to the list
          # if the status is not text add only the operator
          if status == "text" do
            charDetector(
              tail,
              list <>
                "<span class=\"text\">" <>
                val <>
                "</span>" <>
                "<span class=\"operator\">" <> head <> "</span>",
              "",
              ""
            )
          else
            charDetector(tail, list <> "<span class=\"operator\">" <> head <> "</span>", "", "")
          end

        "@" ->
          charDetector(
            tail,
            list <> "<span class=\"decorator\">" <> head <> "</span>",
            "decorator",
            ""
          )

        # if the char is = or !
        a when a in ["=", "!"] ->
          # if the status is text and the operator to the list
          # if the status is not text add only the operator
          if status == "text" do
            charDetector(
              tail,
              list <>
                "<span class=\"variable\">" <>
                val <>
                " </span>" <>
                "<span class=\"operator\">" <> head <> " </span>",
              "",
              ""
            )
          else
            charDetector(tail, list <> "<span class=\"operator\">" <> head <> "</span>", "", "")
          end

        "." ->
          # if the status is text and the . to the list
          # if the status is not text add only the .
          if status == "text" do
            charDetector(
              tail,
              list <> "<span class=\"keyword\">" <> val <> "</span>",
              "method",
              head
            )
          else
            charDetector(tail, list <> "<span class=\"number\">" <> head <> "</span>", "", "")
          end

        # if the char is t or f
        a when val in ["true", "false"] ->
          charDetector(
            tail,
            list <> "<span class=\"boolean\">" <> val <> "</span>",
            "boolean",
            ""
          )

        # if the char is a keyword inside the list
        a
        when val in [
               "print",
               "def",
               "int",
               "if",
               "else",
               "elif",
               "for",
               "while",
               "in ",
               "return",
               "from",
               "import",
               "break"
             ] ->
          # add the keyword to the list
          charDetector(
            tail,
            list <> "<span class=\"keyword\">" <> val <> " </span>",
            "keyword",
            ""
          )

        " " ->
          # if the char is a space and the val is not empty add the val to the list
          # if the char is a space and the val is empty add a space to the list
          if val != "" do
            charDetector(tail, list <> "<span class=\"text\">" <> val <> " </span>", "", "")
          else
            charDetector(tail, list <> "<span> </span>", "", "")
          end

        # if the char is not any of the above add it to the val and change status to text
        _ ->
          charDetector(tail, list, "text", val <> head)
      end
    end
  end

  defp helperFun(line) do
    charDetector(String.graphemes(line <> " • "), "", "", "")
  end

  defp build_html_content(highlighted_text) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Syntax Highlighter</title>
        <style>
            .string { color: green; }
            .comment { color: gray; }
            .keyword { color: blue; }
            .number { color: purple; }
            .operator { color: red; }
            .boolean { color: orange; }
            .function { color: brown; }
            .parenthesis { color: brown; }
            .method { color: brown; }
            .decorator { color: grey; }
            .variable { color: brown; }
            .text { color:black }
        </style>
    </head>
    <body>
    <pre>
    #{highlighted_text}
    </pre>
    </body>
    </html>
    """
  end
end

# Helper module to time the execution of a function (for speedup comparison)
defmodule Timing do
  def time_execution(fun) do
    :timer.tc(fun)
    # Get the time in microseconds
    |> elem(0)
    # Convert to seconds
    |> Kernel./(1_000_000)
    |> IO.inspect(label: "Time in seconds")
  end
end
