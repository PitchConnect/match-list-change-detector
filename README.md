# Match List Change Detector

[![CI](https://github.com/timmybird/match-list-change-detector/actions/workflows/ci.yml/badge.svg)](https://github.com/timmybird/match-list-change-detector/actions/workflows/ci.yml)
[![Docker](https://github.com/timmybird/match-list-change-detector/actions/workflows/docker.yml/badge.svg)](https://github.com/timmybird/match-list-change-detector/actions/workflows/docker.yml)
[![Security](https://github.com/timmybird/match-list-change-detector/actions/workflows/security.yml/badge.svg)](https://github.com/timmybird/match-list-change-detector/actions/workflows/security.yml)

A Python application that detects changes in your football referee match list and triggers actions when changes are found.

## Overview

This application:
1. Fetches your upcoming matches from the FOGIS API
2. Compares them with previously saved matches
3. Detects any changes (new matches, cancelled matches, time changes, etc.)
4. If changes are detected, triggers a docker-compose file to handle the changes
5. Saves the current matches for future comparisons

## Service Modes

The application supports two execution modes:

### 🔄 **Persistent Service Mode** (Recommended)
- **Long-running service** with internal cron scheduling
- **HTTP server** for health checks and manual triggers
- **Configurable scheduling** via environment variables
- **Better operational visibility** and monitoring
- **No restart loops** - runs continuously

### ⚡ **Oneshot Mode** (Legacy)
- **Run once and exit** (original behavior)
- Suitable for external cron scheduling
- Backward compatible with existing deployments

## Security

This application follows security best practices:
- Uses absolute paths for executables to prevent path traversal attacks
- Validates all file paths to prevent directory traversal attacks
- Implements secure credential handling with password masking in logs
- Supports HTTPS for health and metrics servers
- Implements rate limiting for API requests
- Adds security headers to HTTP responses
- Implements proper error handling and logging
- Runs regular security scans with bandit

## Requirements

- Docker and Docker Compose
- FOGIS API credentials (username and password)

## Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/timmybird/match-list-change-detector.git
   cd match_list_change_detector
   ```

2. Create a `.env` file based on the example:
   ```bash
   cp .env.example .env
   ```

3. Edit the `.env` file with your FOGIS credentials and other settings:
   ```bash
   # Open with your favorite editor
   nano .env
   ```

4. Create required directories:
   ```bash
   mkdir -p data logs
   ```

5. Create a docker-compose.override.yml file (optional):
   ```bash
   cp docker-compose.override.yml.example docker-compose.override.yml
   ```

6. Customize the orchestrator docker-compose file to include your actual services for:
   - Syncing matches to your calendar
   - Adding referee contact information to Google contacts
   - Creating assets for WhatsApp groups

## Usage

### Running Manually

To run the change detector manually:

```bash
# Using the run script
./run_detector.sh

# Or using Docker Compose
docker-compose up match-list-change-detector
```

### Running on a Schedule

To run the change detector on an hourly schedule:

```bash
docker-compose -f scheduled-docker-compose.yml up -d
```

This will create a scheduler container that runs the change detector every hour.

### Running Tests

To run the tests:

```bash
# Using the run script
./run_tests.sh

# Or manually
source .venv/bin/activate
python -m unittest discover -s tests
```

## How It Works

1. The application fetches your match list from the FOGIS API using the `fogis-api-client-timmyBird` package.
2. It compares the current match list with the previously saved list.
3. If changes are detected, it saves the changes to a JSON file and triggers the orchestrator docker-compose file.
4. The orchestrator services can then read the changes from the JSON file and perform their respective actions.

## Project Structure

### Core Files
- `match_list_change_detector.py`: The main Python script that detects changes
- `config.py`: Configuration management
- `logging_config.py`: Centralized logging configuration
- `health_server.py`: Simple health check server
- `metrics.py`: Prometheus metrics collection

### Docker Files
- `Dockerfile`: Containerizes the Python script
- `docker-compose.yml`: Defines the change detector service
- `docker-compose.override.yml.example`: Example override file for local customization
- `scheduled-docker-compose.yml`: Sets up a scheduler to run the change detector on a schedule

### Scripts
- `run_detector.sh`: Script to run the detector
- `run_test.sh`: Script to run the API client test with interactive credentials
- `run_test_with_env.sh`: Script to run the API client test with .env credentials
- `run_tests.sh`: Script to run all unit tests

### Configuration
- `.env.example`: Example environment variables file
- `requirements.txt`: Lists the Python dependencies
- `setup.cfg`: Configuration for development tools (flake8, etc.)
- `pyproject.toml`: Configuration for Black, isort, and mypy
- `.pre-commit-config.yaml`: Pre-commit hooks configuration

### Documentation
- `docs/`: Sphinx documentation
  - `docs/source/`: Documentation source files
  - `docs/build/html/`: Generated HTML documentation

### Tests
- `tests/`: Directory containing unit tests

## Logs

Logs are written to the `logs` directory and are also available in the container logs:

```bash
# View logs in the logs directory
cat logs/match_list_change_detector.log

# Or view container logs
docker logs match-list-change-detector
```

## Configuration

You can customize the behavior of the change detector by modifying the following environment variables in your `.env` file:

### Service Mode Configuration (NEW)
- `RUN_MODE`: Service execution mode (`service` for persistent mode, `oneshot` for legacy mode) (default: `service`)
- `CRON_SCHEDULE`: Cron pattern for scheduled execution in service mode (default: `0 * * * *` - hourly)
- `HEALTH_SERVER_PORT`: Port for HTTP health server (default: `8000`)
- `HEALTH_SERVER_HOST`: Host for HTTP health server (default: `0.0.0.0`)

### API Credentials
- `FOGIS_USERNAME`: Your FOGIS username
- `FOGIS_PASSWORD`: Your FOGIS password

### Match List Configuration
- `DAYS_BACK`: Number of days in the past to include in the match list (default: 7)
- `DAYS_AHEAD`: Number of days in the future to include in the match list (default: 365)
- `PREVIOUS_MATCHES_FILE`: File to store previous matches (default: previous_matches.json)

### Orchestrator Configuration
- `DOCKER_COMPOSE_FILE`: Path to the orchestrator docker-compose file (default: ../MatchListProcessor/docker-compose.yml)

### Logging Configuration
- `LOG_LEVEL`: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL) (default: INFO)
- `LOG_DIR`: Directory to store log files (default: logs)
- `LOG_FILE`: Log file name (default: match_list_change_detector.log)

### Docker Configuration
- `CONTAINER_NETWORK`: Docker network to use (default: fogis-network)

### Timezone
- `TZ`: Timezone (default: Europe/Stockholm)

## Usage Examples

### Persistent Service Mode (Recommended)

Run as a long-running service with internal scheduling:

```bash
# Using docker-compose (recommended)
docker-compose up -d

# Or using Docker directly
docker run -d \
  -e RUN_MODE=service \
  -e CRON_SCHEDULE="0 * * * *" \
  -e FOGIS_USERNAME="your_username" \
  -e FOGIS_PASSWORD="your_password" \
  -p 8000:8000 \
  --name match-list-change-detector \
  match-list-change-detector
```

#### HTTP Endpoints

When running in service mode, the following HTTP endpoints are available:

- **Health Check**: `GET http://localhost:8000/health`
  ```json
  {
    "service_name": "match-list-change-detector",
    "status": "healthy",
    "run_mode": "service",
    "cron_schedule": "0 * * * *",
    "last_execution": "2025-07-14T19:11:23.628903",
    "next_execution": "2025-07-14T20:00:00",
    "execution_count": 1,
    "uptime_seconds": 3600.5,
    "timestamp": "2025-07-14T19:11:32.270506"
  }
  ```

- **Manual Trigger**: `POST http://localhost:8000/trigger`
  ```json
  {
    "status": "success",
    "message": "Change detection executed successfully"
  }
  ```

- **Service Status**: `GET http://localhost:8000/status`
  ```json
  {
    "service_name": "match-list-change-detector",
    "run_mode": "service",
    "running": true,
    "cron_schedule": "0 * * * *",
    "configuration": {
      "health_server_port": 8000,
      "fogis_username": "your_username",
      "fogis_password_set": true
    }
  }
  ```

#### Cron Schedule Examples

- `0 * * * *` - Every hour at minute 0
- `*/30 * * * *` - Every 30 minutes
- `0 9,17 * * *` - At 9:00 AM and 5:00 PM daily
- `0 9 * * 1-5` - At 9:00 AM on weekdays only

### Oneshot Mode (Legacy)

Run once and exit (original behavior):

```bash
# Set RUN_MODE to oneshot
docker run --rm \
  -e RUN_MODE=oneshot \
  -e FOGIS_USERNAME="your_username" \
  -e FOGIS_PASSWORD="your_password" \
  match-list-change-detector
```

### Migration from Oneshot to Service Mode

If you're currently using external cron scheduling with oneshot mode, you can migrate to service mode:

1. **Update your docker-compose.yml**:
   ```yaml
   environment:
     - RUN_MODE=service                    # Change from oneshot
     - CRON_SCHEDULE=0 * * * *            # Set your desired schedule
   ```

2. **Remove external cron jobs** that were triggering the oneshot mode

3. **Add health checks** to your monitoring system:
   ```bash
   curl -f http://localhost:8000/health
   ```

4. **Restart the service**:
   ```bash
   docker-compose up -d
   ```

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment:

### Workflows

- **CI**: Runs tests and linting on Python 3.9, 3.10, and 3.11
- **Docker**: Builds and publishes Docker images to GitHub Container Registry
- **Security**: Runs security scans including CodeQL and Bandit
- **Dependencies**: Automatically updates dependencies weekly
- **Release**: Creates GitHub releases when tags are pushed
- **Stale**: Marks and closes stale issues and pull requests
- **Labeler**: Automatically labels pull requests based on changed files
- **Greetings**: Welcomes new contributors

### Docker Images

Docker images are automatically built and published to GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/timmybird/match-list-change-detector:main

# Or pull a specific version
docker pull ghcr.io/timmybird/match-list-change-detector:v1.0.0
```

## Contributing

Contributions are welcome! Here's how you can contribute:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-new-feature`
3. Make your changes
4. Run the tests: `./run_tests.sh`
5. Commit your changes: `git commit -am 'Add some feature'`
6. Push to the branch: `git push origin feature/my-new-feature`
7. Submit a pull request

### Development Setup

#### Quick Setup (Recommended)

For a complete setup or when switching computers, use our all-in-one script:

```bash
# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate

# Run the comprehensive setup script
./scripts/update_environment.sh
```

This script will:
- Install all dependencies
- Set up pre-commit and pre-push hooks
- Configure a post-merge hook to remind you when scripts change
- Verify your local environment

#### Manual Setup

If you prefer to set things up manually:

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Install git hooks:
   ```bash
   # Install pre-commit hooks
   pre-commit install

   # Install pre-push hooks
   ./scripts/install_hooks.sh

   # Set up post-merge hook (optional but recommended)
   ./scripts/setup_post_merge_hook.sh
   ```

4. Verify your local environment:
   ```bash
   # Verify that local checks are properly configured
   ./scripts/verify_local_checks.sh
   ```

5. Run the tests:
   ```bash
   ./run_tests.sh
   ```

6. Build the documentation:
   ```bash
   cd docs && make html
   ```
   Then open `docs/build/html/index.html` in your browser.

### Understanding Git Hooks

This project uses several types of Git hooks to maintain code quality:

- **Pre-commit hooks**: Run automatically when you commit code to check formatting and style
- **Pre-push hooks**: Run automatically before pushing to catch more serious issues
- **Post-merge hooks**: Run after pulling/merging to notify you when scripts have changed

If you update any scripts or pull changes that modify scripts, run `./scripts/update_environment.sh` to ensure your hooks are up to date.

### Script Versioning and Future Updates

Our setup scripts use a version system to track compatibility:

- **Current Version**: 1.0 (Some checks are skipped due to known issues)
- **Future Version**: 2.0 (Will enable all checks after issues #3, #4, and #5 are complete)

The scripts will warn you if they detect a version mismatch. After issues #3, #4, and #5 are complete, we'll update the scripts to version 2.0 (tracked in [issue #6](https://github.com/timmybird/match-list-change-detector/issues/6)).
