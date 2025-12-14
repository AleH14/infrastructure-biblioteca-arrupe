# 🧪 Guía de Pruebas - Sistema de Refresh Tokens

## 1. Verificar Cookie HttpOnly en Login

### Pasos:
1. Abre el navegador y ve a `http://localhost:3000/login`
2. Abre las **DevTools** (F12) → pestaña **Network**
3. Inicia sesión con credenciales válidas
4. Busca la petición `POST /api/auth/login`
5. Ve a la pestaña **Headers** → sección **Response Headers**
6. Busca: `Set-Cookie: refreshToken=...`

### ✅ Verificaciones:
- [ ] La cookie tiene flag `HttpOnly`
- [ ] La cookie tiene `Path=/api/auth/refreshToken`
- [ ] La cookie tiene `SameSite=Strict`
- [ ] La cookie tiene `Max-Age` (aprox. 604800 = 7 días)

### Verificar en Application Tab:
1. DevTools → pestaña **Application**
2. Sidebar → **Cookies** → `http://localhost:3000`
3. Deberías ver:
   - `refreshToken` con ✅ en columna `HttpOnly`
   - No deberías poder leer esta cookie desde `document.cookie` en consola

---

## 2. Verificar Access Token en LocalStorage

### Pasos:
1. Después de login exitoso
2. DevTools → **Application** → **Local Storage** → `http://localhost:3000`

### ✅ Verificaciones:
- [ ] Existe `authToken` con un JWT (empieza con `eyJ...`)
- [ ] Existe `userData` con JSON del usuario
- [ ] En consola ejecuta: `localStorage.getItem('authToken')`
- [ ] Copia el token y decodifícalo en https://jwt.io
- [ ] Verifica que `exp` esté ~15 minutos en el futuro

---

## 3. Verificar Refresh Automático (Interceptor)

### Método 1: Esperar expiración natural
1. Inicia sesión
2. **Espera 15+ minutos** (access token expira)
3. Haz cualquier acción (ir a Usuarios, Catálogo, etc.)
4. DevTools → **Network**

### ✅ Verificaciones:
- [ ] Deberías ver: 
   - Primera petición → `401 Unauthorized`
   - Luego automáticamente: `POST /api/auth/refreshToken` → `200 OK`
   - Luego reintento de petición original → `200 OK`
- [ ] El usuario NO fue redirigido al login
- [ ] La acción se completó exitosamente

### Método 2: Forzar expiración (más rápido)
1. Inicia sesión
2. En consola:
```javascript
// Modificar el token para que esté expirado
const fakeExpiredToken = localStorage.getItem('authToken').slice(0, -10) + 'AAAAAAAAAA';
localStorage.setItem('authToken', fakeExpiredToken);
```
3. Recarga la página o haz una acción
4. Verifica Network tab

---

## 4. Verificar Refresh Proactivo (Timer)

### Pasos:
1. Inicia sesión
2. Abre DevTools → **Console**
3. **Espera 14 minutos** (timer configurado)
4. Deberías ver en consola:
```
AuthContext - Refreshing token automatically...
AuthContext - Token refreshed automatically
```
5. Ve a Network tab:
   - Deberías ver `POST /api/auth/refreshToken` → `200 OK`
6. Verifica LocalStorage:
   - `authToken` debería tener un nuevo valor (diferente al anterior)

### ✅ Verificaciones:
- [ ] El refresh se ejecuta automáticamente sin interacción
- [ ] El nuevo token tiene nueva fecha de expiración (+15 min)
- [ ] El usuario sigue autenticado sin interrupciones

---

## 5. Verificar Logout y Revocación

### Pasos:
1. Inicia sesión (obtendrás cookie refreshToken)
2. Ve a Application → Cookies → verifica que `refreshToken` existe
3. Haz clic en **Cerrar Sesión**
4. Verifica Network tab: `POST /api/auth/logout`

### ✅ Verificaciones:
- [ ] La petición de logout lleva: `Authorization: Bearer <accessToken>`
- [ ] La cookie `refreshToken` se envía automáticamente
- [ ] Response: `200 OK` con mensaje de éxito
- [ ] La cookie `refreshToken` es borrada (Application → Cookies vacío)
- [ ] LocalStorage limpio: no hay `authToken` ni `userData`
- [ ] Redirigido a `/login`

### Verificar revocación en backend:
```bash
# Conectar a MongoDB y verificar que el refresh token fue revocado
docker compose exec mongo mongosh biblioteca-arrupe
db.refreshtokens.find({ usuarioId: ObjectId("TU_USER_ID") })
```
- [ ] Debería tener `fechaRevocacion` con timestamp reciente

---

## 6. Verificar Sincronización entre Pestañas

### Pasos:
1. Abre `http://localhost:3000/login` en **Pestaña 1**
2. Inicia sesión
3. Ve al dashboard
4. Abre `http://localhost:3000/dashboard` en **Pestaña 2** (misma ventana)
5. En **Pestaña 1**, haz logout

### ✅ Verificaciones:
- [ ] **Pestaña 2** debería detectar el cambio automáticamente
- [ ] **Pestaña 2** debería redirigir a `/login` sin necesidad de recargar
- [ ] Verifica consola de Pestaña 2: `AuthContext - Token removed in another tab`

### Prueba inversa (login en otra pestaña):
1. Pestaña 1: login y ve a dashboard
2. Pestaña 2: abre `/login` y haz login con OTRO usuario
3. Pestaña 1 debería actualizar el usuario automáticamente

---

## 7. Verificar Manejo de Refresh Token Inválido

### Escenario: Cookie revocada o expirada
1. Inicia sesión
2. En backend, revoca manualmente el refresh token:
```bash
docker compose exec mongo mongosh biblioteca-arrupe
db.refreshtokens.updateMany(
  { usuarioId: ObjectId("TU_USER_ID") },
  { $set: { fechaRevocacion: new Date() } }
)
```
3. En frontend, espera a que expire el access token (15 min) o fuérzalo:
```javascript
localStorage.setItem('authToken', 'token_invalido');
```
4. Intenta hacer una acción (ir a Usuarios, etc.)

### ✅ Verificaciones:
- [ ] Primera petición → `401`
- [ ] Intento de refresh → `POST /api/auth/refreshToken` → `401`
- [ ] LocalStorage limpiado automáticamente
- [ ] Usuario redirigido a `/login`
- [ ] No hay errores en consola (manejo elegante)

---

## 8. Verificar Seguridad

### XSS Protection:
1. Abre consola del navegador
2. Intenta leer la cookie:
```javascript
document.cookie
```
### ✅ Verificaciones:
- [ ] `refreshToken` NO aparece en la salida (es HttpOnly)
- [ ] Solo cookies accesibles desde JS aparecen

### CSRF Protection:
1. Verifica que la cookie tiene `SameSite=Strict`
2. Esto previene que sitios externos hagan peticiones a tu API

---

## 9. Verificar Rotación de Tokens

### Pasos:
1. Inicia sesión
2. Anota el valor de `authToken` en localStorage
3. Espera 14-15 minutos (para que se ejecute refresh automático o manual)
4. Compara el nuevo `authToken`

### ✅ Verificaciones:
- [ ] El token cambió (rotación exitosa)
- [ ] El token antiguo ya no funciona
- [ ] En MongoDB deberías ver:
   - Token nuevo sin `fechaRevocacion`
   - Token antiguo con `fechaRevocacion` y campo `reemplazadoPor`

---

## 10. Test de Carga (Múltiples Refreshes)

### Pasos:
1. Inicia sesión
2. Abre 3-5 pestañas con diferentes páginas del dashboard
3. Deja que expire el access token
4. En TODAS las pestañas, haz una acción al mismo tiempo

### ✅ Verificaciones:
- [ ] Solo se hace UNA petición a `/api/auth/refreshToken`
- [ ] Las otras peticiones esperan en cola (verifica network timing)
- [ ] Todas las peticiones se completan exitosamente
- [ ] No hay errores 401 permanentes

---

## 📊 Resumen de Verificaciones

| Test | Descripción | Estado |
|------|-------------|--------|
| 1 | Cookie HttpOnly establecida en login | ⬜ |
| 2 | Access token en localStorage | ⬜ |
| 3 | Refresh automático con interceptor | ⬜ |
| 4 | Refresh proactivo (timer 14 min) | ⬜ |
| 5 | Logout revoca refresh token | ⬜ |
| 6 | Sincronización entre pestañas | ⬜ |
| 7 | Manejo de token inválido | ⬜ |
| 8 | Seguridad (HttpOnly, SameSite) | ⬜ |
| 9 | Rotación de tokens | ⬜ |
| 10 | Múltiples refreshes simultáneos | ⬜ |

---

## 🛠️ Herramientas Útiles

### Browser DevTools
- **Network**: Ver peticiones HTTP, headers, cookies
- **Application**: Ver localStorage, cookies
- **Console**: Logs y debugging

### JWT Decoder
- https://jwt.io - Decodifica access tokens

### MongoDB Shell
```bash
docker compose exec mongo mongosh biblioteca-arrupe

# Ver refresh tokens de un usuario
db.refreshtokens.find({ usuarioId: ObjectId("USER_ID") }).pretty()

# Ver todos los tokens activos
db.refreshtokens.find({ fechaRevocacion: null }).pretty()

# Contar tokens por usuario
db.refreshtokens.aggregate([
  { $group: { _id: "$usuarioId", count: { $sum: 1 } } }
])
```

### cURL (Test de endpoints)
```bash
# Login
curl -v -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@biblioteca.com","password":"password"}' \
  -c cookies.txt

# Refresh (usando cookie guardada)
curl -v -X POST http://localhost:4000/api/auth/refreshToken \
  -b cookies.txt

# Logout
curl -v -X POST http://localhost:4000/api/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -b cookies.txt
```

---

## 🚨 Problemas Comunes

### "Error refrescando token automáticamente"
- Verifica que el backend está corriendo
- Verifica que la cookie refreshToken existe en Application tab
- Verifica que no está expirada (Max-Age)

### "Cookie no se establece"
- Verifica `withCredentials: true` en axios config
- Verifica que frontend y backend están en el mismo dominio/puerto válido
- Verifica CORS en backend permite credentials

### "Token no se renueva automáticamente"
- Verifica timer en consola (debería ver logs a los 14 min)
- Verifica que no hay errores en la respuesta de refresh
- Verifica que el componente no se desmonta antes del refresh

---

**✨ Si todos los tests pasan, tu sistema OAuth 2.0 está funcionando perfectamente!**
