# Guía Visual: Carga de Documentos

## 📸 Vista Previa del Widget de Documentos

### Estado: Sin Documento
```
┌────────────────────────────────────────────────┐
│  ┌──────┐                                      │
│  │      │  Documento SOAT                      │
│  │  📁  │  Toca para seleccionar    ⊕         │
│  │      │  Foto o PDF del SOAT                 │
│  └──────┘                                      │
└────────────────────────────────────────────────┘
```

### Estado: Imagen Cargada
```
┌────────────────────────────────────────────────┐
│  ┌──────┐                                      │
│  │ 🖼️   │  Documento SOAT                      │
│  │[IMG] │  soat_2025.jpg           ✓          │
│  └──────┘                                      │
│                                                 │
│  [ 👁️  Ver imagen completa ]                   │
└────────────────────────────────────────────────┘
```

### Estado: PDF Cargado
```
┌────────────────────────────────────────────────┐
│  ┌──────┐                                      │
│  │ 📄   │  Certificado Tecnomecánica           │
│  │ PDF  │  tecnomecanica.pdf       ✓          │
│  └──────┘                                      │
└────────────────────────────────────────────────┘
```

## 📋 Selector de Fuente

Cuando el usuario toca el widget, aparece un bottom sheet:

```
╔══════════════════════════════════════════════╗
║                                              ║
║          Seleccionar documento               ║
║                                              ║
║  ┌──────────────────────────────────────┐  ║
║  │  📷  Tomar foto                       │  ║
║  │      Usa la cámara                    │  ║
║  └──────────────────────────────────────┘  ║
║                                              ║
║  ┌──────────────────────────────────────┐  ║
║  │  🖼️  Galería de fotos                │  ║
║  │      Selecciona una imagen            │  ║
║  └──────────────────────────────────────┘  ║
║                                              ║
║  ┌──────────────────────────────────────┐  ║
║  │  📄  Archivo PDF                      │  ║
║  │      Selecciona un documento PDF      │  ║
║  └──────────────────────────────────────┘  ║
║                                              ║
╚══════════════════════════════════════════════╝
```

## 🔍 Vista Ampliada de Imagen

Al tocar "Ver imagen completa":

```
╔═══════════════════════════════════════════════╗
║                                          ✕    ║
║                                               ║
║          ┌─────────────────────┐             ║
║          │                     │             ║
║          │                     │             ║
║          │   [Imagen SOAT]     │             ║
║          │    ampliada aquí    │             ║
║          │                     │             ║
║          │                     │             ║
║          └─────────────────────┘             ║
║                                               ║
║   ┌─────────────────────────────────────┐   ║
║   │  📄 Documento SOAT                   │   ║
║   │  soat_2025.jpg                       │   ║
║   └─────────────────────────────────────┘   ║
╚═══════════════════════════════════════════════╝
```

## 📱 Flujo de Pantallas

### Registro de Licencia
```
┌──────────────────────────────┐
│ ← Registrar Licencia         │
├──────────────────────────────┤
│                              │
│  🪪 Licencia de Conducción   │
│                              │
│  [Número de Licencia]        │
│  [Categoría]                 │
│  [Fecha Expedición]          │
│  [Fecha Vencimiento]         │
│                              │
│  📸 Foto de la Licencia      │
│  [Widget de Documento]       │
│                              │
│  [ Guardar Licencia ]        │
│                              │
└──────────────────────────────┘
```

### Registro de Documentos del Vehículo
```
┌──────────────────────────────┐
│ ← Registrar Vehículo         │
├──────────────────────────────┤
│ ① Licencia  ② Vehículo  ③ Doc│
│                              │
│  📄 Documentos del Vehículo  │
│                              │
│  🛡️ SOAT                     │
│  [Número SOAT]               │
│  [Vencimiento]               │
│  [Widget de Documento]       │
│  ─────────────────────────   │
│                              │
│  🔧 Tecnomecánica            │
│  [Número]                    │
│  [Vencimiento]               │
│  [Widget de Documento]       │
│  ─────────────────────────   │
│                              │
│  💳 Tarjeta de Propiedad     │
│  [Número]                    │
│  [Widget de Documento]       │
│                              │
│  [ Guardar ]                 │
│                              │
└──────────────────────────────┘
```

## 🎨 Código de Colores

- **Amarillo (#FFFF00)**: Elementos activos y seleccionados
- **Negro (#000000)**: Fondo principal
- **Gris oscuro (#1A1A1A)**: Fondo de widgets
- **Blanco**: Texto principal
- **Rojo**: Documentos vencidos o errores
- **Verde**: Confirmaciones exitosas

## ⚡ Interacciones

| Acción | Resultado |
|--------|-----------|
| Toca widget vacío | Abre selector de fuente |
| Toca "Ver imagen completa" | Muestra modal con imagen ampliada |
| Toca botón ✕ en documento | Elimina el documento cargado |
| Selecciona cámara | Abre cámara nativa |
| Selecciona galería | Abre selector de imágenes |
| Selecciona PDF | Abre explorador de archivos |

## 📊 Validaciones Visuales

### Documento Requerido sin Cargar
```
┌────────────────────────────────────────────────┐
│  ┌──────┐                          [Requerido] │
│  │      │  Documento SOAT                      │
│  │  📁  │  Toca para seleccionar    ⊕         │
│  └──────┘                                      │
└────────────────────────────────────────────────┘
```

### Documento Cargado y Válido
```
┌────────────────────────────────────────────────┐
│  ┌──────┐                                      │
│  │ 🖼️   │  Documento SOAT                  ✓  │
│  │[IMG] │  soat_2025.jpg                      │
│  └──────┘                                      │
└────────────────────────────────────────────────┘
```

### Alerta de Documento Vencido
```
┌────────────────────────────────────────────────┐
│  ⚠️ Tu licencia está vencida                   │
│  Debes renovarla para poder recibir viajes    │
└────────────────────────────────────────────────┘
```
