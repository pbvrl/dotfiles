#!/usr/bin/env bash

# Get an overview of the biggest files/folders in a repository.

# Requires:
#  https://github.com/boyter/scc
#  https://github.com/01mf02/jaq (jq clone)
#  https://github.com/red-data-tools/YouPlot

# Built with AI.

: '
Example output:

                        Top 30 Files by LoC, hierarchically sorted
                        ┌                                        ┐
src/config/mod.rs       ┤■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 2738.0
src/config/session.rs   ┤■■■■■■■ 629.0
src/config/agent.rs     ┤■■■■■■■ 563.0
src/config/input.rs     ┤■■■■■■ 543.0
src/config/role.rs      ┤■■■■■ 398.0
src/client/common.rs    ┤■■■■■■■■ 676.0
src/client/bedrock.rs   ┤■■■■■■■ 633.0
src/client/vertexai.rs  ┤■■■■■■ 537.0
src/client/model.rs     ┤■■■■■ 407.0
src/client/openai.rs    ┤■■■■■ 406.0
src/client/claude.rs    ┤■■■■ 355.0
src/client/stream.rs    ┤■■■ 296.0
src/client/cohere.rs    ┤■■■ 255.0
src/client/macros.rs    ┤■■■ 245.0
src/client/message.rs   ┤■■■ 235.0
models.yaml             ┤■■■■■■■■■■■■■■■■■■■■■■■ 1942.0
Argcfile.sh             ┤■■■■■ 459.0
config.example.yaml     ┤■■■■ 316.0
assets/playground.html  ┤■■■■■■■■■■■■■■■■■■■ 1589.0
assets/arena.html       ┤■■■■■■■■■■■■■ 1106.0
src/serve.rs            ┤■■■■■■■■■■■ 935.0
src/main.rs             ┤■■■■■ 397.0
src/function.rs         ┤■■■■ 309.0
src/rag/mod.rs          ┤■■■■■■■■■■■■ 1013.0
src/utils/request.rs    ┤■■■■■ 464.0
src/utils/path.rs       ┤■■■ 269.0
src/utils/mod.rs        ┤■■■ 247.0
src/repl/mod.rs         ┤■■■■■■■■■■■ 948.0
src/rag/splitter/mod.rs ┤■■■■■■ 475.0
src/render/markdown.rs  ┤■■■■■ 393.0
'

NUM_FILES=${1:-30}
HIERARCHICAL_SORTING_DEPTH=${2:-3}
TITLE="Top ${NUM_FILES} Files by LoC, hierarchically sorted"

read -r -d '' sorting_script <<'EOF'
# 1. Start with the Top N files
(
  [.[].Files[] | {path: .Location, loc: .Lines}]
  | sort_by(-.loc)
  | .[:$num_files]
)

# 2. Add a "group_key" based on the specified directory depth.
| map(. + {
    group_key: (
      .path | split("/") as $parts |
      if ($parts | length) > 1 then
        # Take the first N parts of the directory path for the key
        ($parts | .[:-1] | .[:$group_level] | join("/"))
      else
        # Root-level file
        "."
      end
    )
  })

# 3. Group the files by this new, deeper key.
| group_by(.group_key)

# 4. Create group objects with total LoC for sorting.
| map({
    total_loc: (map(.loc) | add),
    group_key: .[0].group_key, # Store the key for a potential alpha sort tie-breaker
    files: .
  })

# 5. Sort GROUPS by their total LoC (descending). Add a secondary
#    alphabetical sort on the group key for deterministic ordering.
| sort_by(-.total_loc, .group_key)

# 6. Flatten back to the "path,loc" stream for the next tool (awk).
| .[] | .files[] | "\(.path),\(.loc)"
EOF

read -r -d '' label_alignment_script <<'EOF'
# 1. First Pass: Read all lines into memory and find the max label length.
{
  labels[NR] = $1
  values[NR] = $2
  if (length($1) > max_len) {
    max_len = length($1)
  }
}
# 2. Second Pass: After all lines are read, print with formatting.
END {
  for (i = 1; i <= NR; i++) {
    # `printf "%-*s"` is the key: it prints a string, left-aligned (`-`),
    # padded with spaces to the width specified by `max_len`.
    printf("%-*s,%s\n", max_len, labels[i], values[i])
  }
}
EOF


# Count lines using scc
scc --by-file -f json . | \
  # Hierarchically sort files using jaq
  jaq -r --argjson num_files "$NUM_FILES" --argjson group_level "$HIERARCHICAL_SORTING_DEPTH" "$sorting_script" | \
  # Align labels using awk
  awk -F, "$label_alignment_script" | \
  # Print barplot using uplot
  RUBYOPT='-W0' uplot bar -d, -m 0 -t "${TITLE}"
