#!/bin/sh

clangd=${CLANGD:-$(which clangd)}

usage() {
    echo "Usage: $(basename $0) [options] [<path/to/compile_commands.json>]"
    echo ""
    echo "Options:"
    echo "-h,--help"
    exit $1
}

opts=$(getopt --options "h" --longoptions "help" --name "$(basename $0)" -- "$@") || usage 1
eval set -- "$opts"

set -e

while true; do
    case "$1" in
        -h|--help)
            usage 0
            ;;
        --)
            shift
            break
            ;;
    esac
done

compile_commands="$1"
if [ -z "$compile_commands" ]; then
    dir=$PWD
    while [ ! -f "$dir/compile_commands.json" ]; do
        dir=$(dirname "$dir")
        if [ "$dir" = "/" ]; then
            break;
        fi
    done
    compile_commands="$dir/compile_commands.json"
fi
[ -f "$compile_commands" ] || usage 1

function terminate {
    kill -9 "${clangd_pid:-}" 2>/dev/null
    rm -f "$fifo"
    rm -f clangd.log
}

trap terminate EXIT

fifo=$(mktemp -u)
mkfifo $fifo

tail -f ${fifo} | $clangd \
    --background-index \
    --compile-commands-dir=$(dirname $compile_commands) \
    --log=info > clangd.log 2>&1 &

clangd_pid=$!

echo "Run $clangd (${clangd_pid})..."

function lsp_msg() {
    msg="$1"
    echo "Content-Length: ${#msg}" > $fifo
    echo "" > $fifo
    echo -n "$msg" > $fifo
}

function lsp_initialize_msg() {
    name=$(basename "$(realpath "$(dirname "$compile_commands")")")
    version=$(code -v 2>/dev/null | head -n1 || "unknown")
    lsp_msg '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"processId":'"$$"',"clientInfo":{"name":"Visual Studio Code","version":"'$version'"},"locale":"en-us","rootPath":"'"$root"'","rootUri":"file://'"$root"'","capabilities":{"workspace":{"applyEdit":true,"workspaceEdit":{"documentChanges":true,"resourceOperations":["create","rename","delete"],"failureHandling":"textOnlyTransactional","normalizesLineEndings":true,"changeAnnotationSupport":{"groupsOnLabel":true}},"configuration":true,"didChangeWatchedFiles":{"dynamicRegistration":true,"relativePatternSupport":true},"symbol":{"dynamicRegistration":true,"symbolKind":{"valueSet":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]},"tagSupport":{"valueSet":[1]},"resolveSupport":{"properties":["location.range"]}},"codeLens":{"refreshSupport":true},"executeCommand":{"dynamicRegistration":true},"didChangeConfiguration":{"dynamicRegistration":true},"workspaceFolders":true,"semanticTokens":{"refreshSupport":true},"fileOperations":{"dynamicRegistration":true,"didCreate":true,"didRename":true,"didDelete":true,"willCreate":true,"willRename":true,"willDelete":true},"inlineValue":{"refreshSupport":true},"inlayHint":{"refreshSupport":true},"diagnostics":{"refreshSupport":true}},"textDocument":{"publishDiagnostics":{"relatedInformation":true,"versionSupport":false,"tagSupport":{"valueSet":[1,2]},"codeDescriptionSupport":true,"dataSupport":true},"synchronization":{"dynamicRegistration":true,"willSave":true,"willSaveWaitUntil":true,"didSave":true},"completion":{"dynamicRegistration":true,"contextSupport":true,"completionItem":{"snippetSupport":true,"commitCharactersSupport":true,"documentationFormat":["markdown","plaintext"],"deprecatedSupport":true,"preselectSupport":true,"tagSupport":{"valueSet":[1]},"insertReplaceSupport":true,"resolveSupport":{"properties":["documentation","detail","additionalTextEdits"]},"insertTextModeSupport":{"valueSet":[1,2]},"labelDetailsSupport":true},"insertTextMode":2,"completionItemKind":{"valueSet":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]},"completionList":{"itemDefaults":["commitCharacters","editRange","insertTextFormat","insertTextMode"]},"editsNearCursor":true},"hover":{"dynamicRegistration":true,"contentFormat":["markdown","plaintext"]},"signatureHelp":{"dynamicRegistration":true,"signatureInformation":{"documentationFormat":["markdown","plaintext"],"parameterInformation":{"labelOffsetSupport":true},"activeParameterSupport":true},"contextSupport":true},"definition":{"dynamicRegistration":true,"linkSupport":true},"references":{"dynamicRegistration":true},"documentHighlight":{"dynamicRegistration":true},"documentSymbol":{"dynamicRegistration":true,"symbolKind":{"valueSet":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]},"hierarchicalDocumentSymbolSupport":true,"tagSupport":{"valueSet":[1]},"labelSupport":true},"codeAction":{"dynamicRegistration":true,"isPreferredSupport":true,"disabledSupport":true,"dataSupport":true,"resolveSupport":{"properties":["edit"]},"codeActionLiteralSupport":{"codeActionKind":{"valueSet":["","quickfix","refactor","refactor.extract","refactor.inline","refactor.rewrite","source","source.organizeImports"]}},"honorsChangeAnnotations":false},"codeLens":{"dynamicRegistration":true},"formatting":{"dynamicRegistration":true},"rangeFormatting":{"dynamicRegistration":true},"onTypeFormatting":{"dynamicRegistration":true},"rename":{"dynamicRegistration":true,"prepareSupport":true,"prepareSupportDefaultBehavior":1,"honorsChangeAnnotations":true},"documentLink":{"dynamicRegistration":true,"tooltipSupport":true},"typeDefinition":{"dynamicRegistration":true,"linkSupport":true},"implementation":{"dynamicRegistration":true,"linkSupport":true},"colorProvider":{"dynamicRegistration":true},"foldingRange":{"dynamicRegistration":true,"rangeLimit":5000,"lineFoldingOnly":true,"foldingRangeKind":{"valueSet":["comment","imports","region"]},"foldingRange":{"collapsedText":false}},"declaration":{"dynamicRegistration":true,"linkSupport":true},"selectionRange":{"dynamicRegistration":true},"callHierarchy":{"dynamicRegistration":true},"semanticTokens":{"dynamicRegistration":true,"tokenTypes":["namespace","type","class","enum","interface","struct","typeParameter","parameter","variable","property","enumMember","event","function","method","macro","keyword","modifier","comment","string","number","regexp","operator","decorator"],"tokenModifiers":["declaration","definition","readonly","static","deprecated","abstract","async","modification","documentation","defaultLibrary"],"formats":["relative"],"requests":{"range":true,"full":{"delta":true}},"multilineTokenSupport":false,"overlappingTokenSupport":false,"serverCancelSupport":true,"augmentsSyntaxTokens":true},"linkedEditingRange":{"dynamicRegistration":true},"typeHierarchy":{"dynamicRegistration":true},"inlineValue":{"dynamicRegistration":true},"inlayHint":{"dynamicRegistration":true,"resolveSupport":{"properties":["tooltip","textEdits","label.tooltip","label.location","label.command"]}},"diagnostic":{"dynamicRegistration":true,"relatedDocumentSupport":false},"inactiveRegionsCapabilities":{"inactiveRegions":true}},"window":{"showMessage":{"messageActionItem":{"additionalPropertiesSupport":true}},"showDocument":{"support":true},"workDoneProgress":true},"general":{"staleRequestSupport":{"cancel":true,"retryOnContentModified":["textDocument/semanticTokens/full","textDocument/semanticTokens/range","textDocument/semanticTokens/full/delta"]},"regularExpressions":{"engine":"ECMAScript","version":"ES2020"},"markdown":{"parser":"marked","version":"1.1.0"},"positionEncodings":["utf-16"]},"notebookDocument":{"synchronization":{"dynamicRegistration":true,"executionSummarySupport":true}}},"initializationOptions":{"clangdFileStatus":true,"fallbackFlags":[]},"trace":"off","workspaceFolders":[{"uri":"file://'"$root"'","name":"'"$name"'"}]}}'
}

function lsp_initialized_msg() {
    lsp_msg '{"jsonrpc":"2.0","method":"initialized","params":{}}'
}

function lsp_did_open_msg() {
    path=$(dirname $(realpath "$compile_commands"))
    file=$(jq -r '.[0].file' "$compile_commands")
    path=$(realpath "$path/$file")
    text=$(cat "$path" | jq -s -R .)
    lang="${path##*.}"
    lsp_msg '{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file://'"$path"'","languageId":"'$lang'","version":1,"text":'"$text"'}}}'
}

function lsp_result_msg() {
    id=${1:-0}
    lsp_msg '{"jsonrpc":"2.0","id":'$id',"result":null}'
}

files=0
progress=

while IFS= read -r line; do
    content_length='Content-Length: ([0-9]+)'
    if [[ "$line" =~ $content_length ]]; then
        read -r
        read -r -n ${BASH_REMATCH[1]} line
    fi

    clangd_version='^I\[[0-9:\.]+\] (.*clangd version.*)'
    starting_lsp='^I\[[0-9:\.]+\] Starting LSP over stdin/stdout$'
    background_index_create='\{"id":([0-9]+),"jsonrpc":"2.0","method":"window/workDoneProgress/create","params":\{"token":"backgroundIndexProgress"\}\}'
    background_index_begin='\{"jsonrpc":"2.0","method":"\$/progress","params":\{"token":"backgroundIndexProgress","value":\{"kind":"begin","percentage":([0-9]+),"title":"indexing"\}\}\}'
    background_index_progress='^\{"jsonrpc":"2.0","method":"\$/progress","params":\{"token":"backgroundIndexProgress","value":\{"kind":"report","message":"(.*)","percentage":([0-9]+)\}\}\}.*$'
    background_index_end='\{"jsonrpc":"2.0","method":"\$/progress","params":\{"token":"backgroundIndexProgress","value":\{"kind":"end"\}\}\}'
    indexed_file='Indexed (\.\./)*([^ ]+) .*'

    if [[ "$line" =~ $clangd_version ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$line" =~ $starting_lsp ]]; then
        lsp_initialize_msg
        lsp_initialized_msg
        lsp_did_open_msg
    elif [[ "$line" =~ $background_index_create ]]; then
        lsp_result_msg "${BASH_REMATCH[1]}"
    elif [[ "$line" =~ $background_index_begin ]]; then
        echo "Preparing index..."
    elif [[ "$line" =~ $background_index_end ]]; then
        if [ $files -eq 0 ]; then
            echo "Up to date."
        else
            echo ""
        fi
        pkill -P $$ tail
        exit 0
    elif [[ "$line" =~ $background_index_progress ]]; then
        progress="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ $indexed_file ]]; then
        files=$((files + 1))
        echo -ne "\r\033[K[$progress] ${BASH_REMATCH[2]}"
    fi
done < <(tail -F -q clangd.log 2>/dev/null)
