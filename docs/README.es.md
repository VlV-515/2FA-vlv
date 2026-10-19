# 2FA-vlv (español)

<p align="center">
  <img src="images/app-icon.png" width="128" height="128" alt="Ícono de 2FA-vlv">
</p>

**Códigos de dos factores para tu Mac. Código abierto, sin conexión y más simple que el original.**

2FA-vlv es un autenticador nativo para macOS. Muestra códigos en vivo con un anillo de cuenta regresiva, copia un código con un clic y guarda tus secretos solo en tu Mac. Sin cuenta, sin suscripción, sin servidor.

## Por qué usarlo

- **Simple.** Una ventana, un buscador, un clic para copiar.
- **Código abierto.** Licencia MIT. Léelo, compílalo, cámbialo.
- **Solo tuyo.** Secretos en el Llavero de macOS (o en un archivo con permisos `0600`).
- **Trae tus códigos.** Importa tu respaldo de LastPass Authenticator. Agrega otros con enlace `otpauth://` o código QR.
- **Organizado.** Favoritos, carpetas, orden por arrastre e ícono de color por servicio.
- **Rápido.** Ícono en la barra de menú y atajo global opcional (`⌃⌥⌘2`).
- **Tu idioma.** Inglés por defecto, español con un clic en Ajustes.

## Instalar

```bash
git clone https://github.com/VlV-515/2fa-vlv.git
cd 2fa-vlv
swift build && ./scripts/package-app.sh && open dist/2FA-vlv.app
```

Más detalles en [la guía de uso](usage.md) y [la guía de instalación](installation.md).

- Código: <https://github.com/VlV-515/2fa-vlv>
- Descargas: <https://sourceforge.net/projects/2fa-vlv/>
