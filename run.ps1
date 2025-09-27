# This script starts all microservices and the CMS frontend as background jobs.
# It is designed to be run from the project root.
# Press Ctrl+C to stop all services gracefully.

try {
	Write-Host "Starting all services in the background..." -ForegroundColor Green

	# Start Python microservices
	Start-Job -Name "users" -ScriptBlock {
		Set-Location services\users
		Write-Host "Starting users service on port 8001..."
		uv sync --all-groups --all-extras
		.\.venv\Scripts\Activate.ps1
		uvicorn main:app --port 8001 --reload
	}

	Start-Job -Name "contents" -ScriptBlock {
		Set-Location services\contents
		Write-Host "Starting contents service on port 8002..."
		uv sync --all-groups --all-extras
		.\.venv\Scripts\Activate.ps1
		uvicorn main:app --port 8002 --reload
	}

	Start-Job -Name "payments" -ScriptBlock {
		Set-Location services\payments
		Write-Host "Starting payments service on port 8003..."
		uv sync --all-groups --all-extras
		.\.venv\Scripts\Activate.ps1
		uvicorn main:app --port 8003 --reload
	}

	Start-Job -Name "opi" -ScriptBlock {
		Set-Location services\_opi
		Write-Host "Starting OPI service on port 8000..."
		uv sync --all-groups --all-extras
		.\.venv\Scripts\Activate.ps1
		uvicorn main:app --port 8000 --reload
	}

	# Start Bun frontend app
	Start-Job -Name "cms" -ScriptBlock {
		Set-Location apps\cms
		Write-Host "Starting CMS app..."
		bun install
		bun run dev
	}

	Write-Host "All services are starting up." -ForegroundColor Green
	Write-Host "Run 'Get-Job' to see the status and 'Receive-Job -Name <job_name> -Keep' to see output."
	Write-Host "Press Ctrl+C to stop all services."

	# Keep the main script alive to wait for Ctrl+C
	while ($true) {
		Start-Sleep -Seconds 1
	}
}
finally {
	# This block runs on exit (including Ctrl+C)
	Write-Host "`nStopping all background services..." -ForegroundColor Yellow
	Get-Job | Stop-Job
	Get-Job | Remove-Job
	Write-Host "All services stopped." -ForegroundColor Green
}
