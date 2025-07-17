#!/bin/bash
# Local CI script to match GitHub Actions CI environment exactly
# This script runs the same tests as the CI pipeline

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Match List Change Detector - Local CI ===${NC}"
echo -e "${BLUE}This script runs the same tests as the CI pipeline${NC}"
echo -e "${BLUE}=================================================${NC}"

# Create necessary directories
mkdir -p logs data

# Check Python version
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${BLUE}Using Python version:${NC} $PYTHON_VERSION"

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
python3 -m pip install --upgrade pip
python3 -m pip install pytest pytest-cov pytest-xdist hypothesis mypy black isort flake8
python3 -m pip install -r requirements.txt

# Run linting
echo -e "${BLUE}Running linting...${NC}"
SKIP=pydocstyle python3 -m flake8 || echo -e "${YELLOW}Linting issues found${NC}"
python3 -m black --check . || echo -e "${YELLOW}Black formatting issues found${NC}"
python3 -m isort --check . || echo -e "${YELLOW}Import sorting issues found${NC}"

# Run type checking
echo -e "${BLUE}Running type checking...${NC}"
python3 -m mypy . || echo -e "${YELLOW}Type checking issues found${NC}"

# Run tests
echo -e "${BLUE}Running tests...${NC}"
export FOGIS_USERNAME=test_user
export FOGIS_PASSWORD=test_pass

# Run property-based tests (matches CI exactly)
echo -e "${BLUE}Running property-based tests (CI scope)...${NC}"
python3 -m pytest tests/test_property_based.py -v --cov=. --cov-report=xml

# Run isolated tests (additional local testing)
echo -e "${BLUE}Running isolated tests...${NC}"
python3 -m pytest tests/test_main_isolated.py tests/test_detector_isolated.py -v

# Run persistent service tests
echo -e "${BLUE}Running persistent service tests...${NC}"
python3 -m pytest tests/test_persistent_service.py -v

# Check coverage
echo -e "${BLUE}Checking coverage...${NC}"
COVERAGE=$(python3 -c "import xml.etree.ElementTree as ET; tree = ET.parse('coverage.xml'); root = tree.getroot(); print(root.attrib['line-rate'])")
COVERAGE_PCT=$(echo "$COVERAGE * 100" | bc)
echo -e "${BLUE}Coverage:${NC} ${COVERAGE_PCT}%"

if (( $(echo "$COVERAGE_PCT < 95" | bc -l) )); then
    echo -e "${RED}Coverage below 95%${NC}"
    exit 1
else
    echo -e "${GREEN}Coverage above 95%${NC}"
fi

echo -e "${GREEN}All tests passed!${NC}"
