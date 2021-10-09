# Watershed Workflow Docker

Containerized version of [Watershed Workflow](https://github.com/ecoon/watershed-workflow)

# Usage

Copy `watershed-workflow-container` to a directory in your path.

`watershed-workflow-container <cmd>`

`<cmd>` can be something like jupyter-notebook or python. The current directory
is mapped into the container. `~/watershed-workflow-data` is mapped to the
`watershed-workflow/data` directory in the container.


