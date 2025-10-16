# Scripts de utilidad para infraestructura

# Función para mostrar el estado de los servicios
function Show-ServiceStatus {
    Write-Host "🔍 Verificando estado de los servicios..." -ForegroundColor Yellow
    docker-compose ps
    Write-Host ""
    
    Write-Host "📊 Uso de recursos:" -ForegroundColor Cyan
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
}

# Función para verificar la conectividad
function Test-Services {
    Write-Host "🧪 Probando conectividad de servicios..." -ForegroundColor Green
    
    # Test frontend
    try {
        $frontend = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
        Write-Host "✅ Frontend: OK (Status: $($frontend.StatusCode))" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Frontend: No disponible" -ForegroundColor Red
    }
    
    # Test backend
    try {
        $backend = Invoke-WebRequest -Uri "http://localhost:4000" -UseBasicParsing -TimeoutSec 5
        Write-Host "✅ Backend: OK (Status: $($backend.StatusCode))" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Backend: No disponible" -ForegroundColor Red
    }
    
    # Test MongoDB
    try {
        $mongoTest = docker exec mongo mongosh --eval "db.adminCommand('ismaster')" --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ MongoDB: OK" -ForegroundColor Green
        } else {
            Write-Host "❌ MongoDB: Error de conexión" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ MongoDB: No disponible" -ForegroundColor Red
    }
}

# Función para limpiar todo
function Clear-Environment {
    Write-Host "🧹 Limpiando entorno..." -ForegroundColor Yellow
    docker-compose down -v --remove-orphans
    docker system prune -f
    Write-Host "✅ Entorno limpiado" -ForegroundColor Green
}

# Función para setup inicial
function Initialize-Project {
    Write-Host "🚀 Inicializando proyecto Biblioteca Arrupe..." -ForegroundColor Cyan
    
    Write-Host "1️⃣ Clonando repositorios..." -ForegroundColor Yellow
    docker-compose --profile setup up cloner
    
    Write-Host "2️⃣ Iniciando servicios..." -ForegroundColor Yellow  
    docker-compose up -d
    
    Write-Host "3️⃣ Esperando que los servicios estén listos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    Write-Host "4️⃣ Verificando servicios..." -ForegroundColor Yellow
    Test-Services
    
    Write-Host "🎉 ¡Proyecto inicializado!" -ForegroundColor Green
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "Backend: http://localhost:4000" -ForegroundColor Cyan
}

# Exportar funciones para uso
Export-ModuleMember -Function Show-ServiceStatus, Test-Services, Clear-Environment, Initialize-Project

# Mostrar ayuda
Write-Host @"
📚 Scripts de Biblioteca Arrupe - Comandos disponibles:

🚀 Initialize-Project    - Configura todo desde cero
🔍 Show-ServiceStatus   - Muestra estado de contenedores
🧪 Test-Services        - Verifica conectividad
🧹 Clear-Environment    - Limpia todo el entorno

Ejemplo de uso:
Initialize-Project
"@ -ForegroundColor White
