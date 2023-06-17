defmodule Syntaxhighlighter do
  def highlight(directory_path) do
    {:ok, path} = :file.get_cwd()
    IO.puts(path)

    read_files_from_folder(directory_path)
    |> Task.async_stream(&highlight_file/1)
    |> Enum.each(fn
      {:ok, result} -> IO.puts("File processed successfully: #{result}")
      {:error, error} -> IO.puts("Error processing file: #{inspect(error)}")
      task when is_struct(task, Task) -> IO.puts("Task error: #{inspect(task)}")
    end)
  end

  defp read_files_from_folder(directory_path) do
    File.ls!(directory_path)
    |> Enum.map(fn file -> Path.join(directory_path, file) end)
  end

  defp highlight_file(file) do
    Task.async(fn ->
      expanded_path = Path.expand(file)

      IO.puts("Reading file: #{expanded_path}")

      case File.read(expanded_path) do
        {:error, _reason} ->
          IO.puts("Failed to read file: #{expanded_path}")
          {:error, :read_failure}

        {:ok, text} ->
          highlighted_text =
            text
            |> String.split(~r/\n/, trim: false)
            |> Enum.map(&helperFun/1)
            |> Enum.join("\n")

          html_content = build_html_content(highlighted_text)

          case File.write("#{Path.basename(expanded_path)}.html", html_content) do
            :ok -> file
            {:error, reason} -> {:error, reason}
          end
      end
    end)
  end

  defp charDetector([head | tail], list, status, val) do
    if tail == [] do
      list
    else
      case head do
        _ when status == "string" ->
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

        a when a in ["\"", "\'"] ->
          charDetector(tail, list, "string", val <> head)

        "(" ->
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
            charDetector(
              tail,
              list <> "<span class=\"parenthesis\">" <> head <> "</span>",
              "",
              ""
            )
          end

        "#" ->
          charDetector(tail, list, "comment", val <> head)

        a when a in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] ->
          charDetector(tail, list <> "<span class=\"number\">" <> head <> "</span>", "", "")

        a when a in ["{", "}", "[", "]", ")"] ->
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

        a when a in [":", ",", ";", "+", "-", "*", "/", "%", "^"] ->
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

        a when a in ["=", "!"] ->
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

        a when val in ["true", "false"] ->
          charDetector(
            tail,
            list <> "<span class=\"boolean\">" <> val <> "</span>",
            "boolean",
            ""
          )

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
          charDetector(
            tail,
            list <> "<span class=\"keyword\">" <> val <> " </span>",
            "keyword",
            ""
          )

        " " ->
          if val != "" do
            charDetector(tail, list <> "<span class=\"text\">" <> val <> " </span>", "", "")
          else
            charDetector(tail, list <> "<span> </span>", "", "")
          end

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

Syntaxhighlighter.highlight("PythonFiles")
