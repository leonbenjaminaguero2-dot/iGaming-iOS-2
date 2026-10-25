# iGaming para iPhone

Lanzador SwiftUI para Xbox Cloud Gaming, GeForce NOW, Luna y Boosteroid. Incluye favoritos, búsqueda, cuentas con enlaces oficiales y detección de mando Bluetooth. **No es un motor de streaming ni incluye juegos:** abre los servicios oficiales. La compatibilidad y el acceso dependen del proveedor.

## Compilar IPA gratis con GitHub Actions

1. Crear un repositorio en GitHub (preferentemente privado) y subir **todos los archivos, incluida la carpeta oculta `.github`**.
2. Abrir **Actions > Build iGaming IPA > Run workflow** (o esperar el build al hacer push a `main`).
3. Al terminar, descargar el artefacto **iGaming-IPA**, descomprimirlo y obtener `iGaming-unsigned.ipa`.
4. Para instalarlo en el iPhone, se requiere firma válida. SideStore puede firmar aplicaciones compatibles con tu Apple ID y sus límites; no garantiza que cualquier IPA sin firmar se instale. Si falla, puede ser necesario firmar con otro método o revisar el log.

## Cambios

- Editá `iGaming/HomeView.swift` para agregar enlaces y juegos.
- Editá `project.yml` para cambiar el bundle ID. Si necesitás regenerar el proyecto local, instalá XcodeGen en macOS y ejecutá `xcodegen generate`.
- El ícono se encuentra en `iGaming/Assets.xcassets/AppIcon.appiconset`.

Este proyecto no incluye credenciales, API privadas ni contenido protegido de terceros.
