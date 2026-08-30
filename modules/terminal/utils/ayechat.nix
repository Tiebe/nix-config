{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "ayechat";
  version = "0.55.3";
  pyproject = true;

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-hu631VYOS83vQVUK98I4C3FCcd9RqUi98B9MU18TG0s=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = with python3Packages; [
    typer
    httpx
    keyring
    prompt-toolkit
    pathspec
    chromadb
    rapidfuzz
    pillow
    # Imported unguarded by aye.model.version_checker / aye.presenter.diff_presenter
    # but missing from upstream's declared dependencies.
    packaging
    pygments
  ];

  # tree-sitter is deliberately absent: aye.model.ast_chunker imports
  # tree_sitter and tree_sitter_languages together behind one try block, and
  # python3Packages.tree-sitter-languages is marked broken in nixpkgs, so the
  # chunker keeps using its graceful non-AST fallback.

  doCheck = false;

  pythonImportsCheck = [
    "aye"
    "aye.model.version_checker"
    "aye.presenter.diff_presenter"
  ];

  meta = {
    description = "Terminal-first AI code generator";
    homepage = "https://ayechat.ai";
    license = lib.licenses.mit;
    mainProgram = "aye";
  };
}
