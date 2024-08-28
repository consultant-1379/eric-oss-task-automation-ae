# OSS TASK AUTOMATION Pre-Code Review Pipeline

## Pipeline used to analyze and build the commits made in com.ericsson.oss.dmi/eric-oss-task-automation-ae

## Flow

### Declarative: Checkout SCM

- Checks out the commit from Gerrit

### Clean Workspace

- Cleans anything that might be left over from previous pipeline runs, e.g. test reports, .tgz files, etc.
- Cleans the workspace using `git clean`

### Package Helm Charts

- Packages the Helm chart and saves it as `eric-oss-task-automation-ae-0.0.0-0.tgz`

### Validate Helm3 Chart Schema

- Validates the Helm chart using the schema
- Scans the helm-chart-validator testsuite `site_values.yaml`

### Validate Helm Chart Schema

- Validates the Helm chart using the schema

### Build Helm Testsuite Image

- Builds a Docker image to be used for tests
    - `docker build <PWD>/<testsuite-dir> --tag <testsuite-image-name>:latest`

### Run Helm Chart Testsuite

- Runs the Helm testsuite using the Docker image created in the previous step
    - `docker run --name <testsuite-image-name> -v PWD/eric-oss-task-automation-ae-<chart-version>.tgz:/eric-oss-task-automation-ae.tgz <testsuite-image-name>:latest`
- After the testsuite has run, a test report is generated inside the Docker container. This is copied out and stored
  in `PWD/chart-test-report.html`
- The container is then removed.
    - `docker rm -f <testsuite-image-name>`

### Python Lint Utilities

- Python linting using Pylint for the Python files in the Gerrit commit
- Skipped when no Python files have been changed

### Design Rules Check

- Runs Helm design rules

### Check shell scripts

- Runs shellcheck against the scripts in the Gerrit commit
- Skipped when no scripts have been changed