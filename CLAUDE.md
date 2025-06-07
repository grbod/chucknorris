# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple Flask API that serves dad jokes from the icanhazdadjoke API (https://icanhazdadjoke.com/). The application is designed for one-click deployment to DigitalOcean App Platform.

## Architecture

- **app.py**: Main Flask application with a single route `/` that fetches and returns jokes
- **wsgi.py**: WSGI entry point for production deployment
- **.do/deploy.template.yaml**: DigitalOcean App Platform deployment configuration

## Development Commands

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run locally (development server)
python app.py
```

### Production Deployment
The app is configured to run with Gunicorn in production:
```bash
gunicorn --worker-tmp-dir /dev/shm wsgi:app
```

## Key Configuration

- **Port**: Application runs on port 8080
- **Host**: Binds to 0.0.0.0 for containerized environments
- **Production server**: Uses Gunicorn with WSGI
- **Dependencies**: Flask 2.3.3, Gunicorn 21.2.0, Requests 2.31.0

## DigitalOcean Deployment

The `.do/deploy.template.yaml` file configures:
- Python environment with automatic dependency installation
- Health check on root path
- Single instance with 1 vCPU, 0.5GB RAM
- Production Flask environment variable