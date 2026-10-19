import Foundation

/// All user-facing text. English first, Spanish second.
struct AppCopy {
    let language: AppLanguage

    private func choose(_ english: String, _ spanish: String) -> String {
        language == .english ? english : spanish
    }

    // MARK: Menus
    var about: String { choose("About \(AppBranding.displayName)", "Acerca de \(AppBranding.displayName)") }
    var preferences: String { choose("Settings...", "Ajustes...") }
    var showApp: String { choose("Show \(AppBranding.displayName)", "Mostrar \(AppBranding.displayName)") }
    var hideApp: String { choose("Hide \(AppBranding.displayName)", "Ocultar \(AppBranding.displayName)") }
    var quit: String { choose("Quit \(AppBranding.displayName)", "Salir de \(AppBranding.displayName)") }
    var lockNow: String { choose("Lock", "Bloquear") }
    var addAccountMenu: String { choose("Add Account...", "Agregar cuenta...") }
    var importLastPassMenu: String { choose("Import LastPass Backup...", "Importar respaldo de LastPass...") }
    var edit: String { choose("Edit", "Edición") }
    var window: String { choose("Window", "Ventana") }

    // MARK: List
    var searchPlaceholder: String { choose("Search accounts", "Buscar cuentas") }
    var favorites: String { choose("Favorites", "Favoritos") }
    var otherAccounts: String { choose("Other accounts", "Otras cuentas") }
    var emptyTitle: String { choose("No accounts yet", "Aún no hay cuentas") }
    var emptyMessage: String {
        choose("Add an account or import your LastPass Authenticator backup.",
               "Agrega una cuenta o importa tu respaldo de LastPass Authenticator.")
    }
    var noResults: String { choose("No matches", "Sin resultados") }
    var emptyFolder: String { choose("Empty folder", "Carpeta vacía") }
    var codeHidden: String { choose("Click to reveal", "Clic para mostrar") }
    var copied: String { choose("Code copied", "Código copiado") }
    var copyCode: String { choose("Copy Code", "Copiar código") }
    var nextCode: String { choose("Next code", "Siguiente código") }
    var addToFavorites: String { choose("Add to Favorites", "Agregar a favoritos") }
    var removeFromFavorites: String { choose("Remove from Favorites", "Quitar de favoritos") }
    var moveToFolder: String { choose("Move to Folder", "Mover a carpeta") }
    var noFolder: String { choose("No folder", "Sin carpeta") }
    var editAccount: String { choose("Edit...", "Editar...") }
    var delete: String { choose("Delete", "Eliminar") }
    var invalidSecretRow: String { choose("Invalid secret", "Secreto inválido") }
    var reorderHint: String { choose("Drag to reorder", "Arrastra para reordenar") }

    // MARK: Toolbar
    var add: String { choose("Add", "Agregar") }
    var manageFolders: String { choose("Manage Folders...", "Administrar carpetas...") }
    var importLastPass: String { choose("Import LastPass Backup...", "Importar respaldo de LastPass...") }
    var settings: String { choose("Settings", "Ajustes") }

    // MARK: Editor
    var addAccountTitle: String { choose("Add Account", "Agregar cuenta") }
    var editAccountTitle: String { choose("Edit Account", "Editar cuenta") }
    var modeManual: String { choose("Manual", "Manual") }
    var modeURI: String { choose("Link", "Enlace") }
    var modeQR: String { choose("QR code", "Código QR") }
    var service: String { choose("Service", "Servicio") }
    var servicePlaceholder: String { choose("GitHub, Google...", "GitHub, Google...") }
    var accountName: String { choose("Account", "Cuenta") }
    var accountPlaceholder: String { choose("name@example.com", "nombre@ejemplo.com") }
    var secretKey: String { choose("Secret key", "Clave secreta") }
    var secretPlaceholder: String { choose("Base32 key, e.g. JBSWY3DPEHPK3PXP", "Clave Base32, ej. JBSWY3DPEHPK3PXP") }
    var secretInvalid: String { choose("Not a valid Base32 key (letters A-Z and digits 2-7).", "No es una clave Base32 válida (letras A-Z y dígitos 2-7).") }
    var secretUnchanged: String { choose("Leave unchanged to keep the current key.", "Déjala igual para conservar la clave actual.") }
    var folder: String { choose("Folder", "Carpeta") }
    var favorite: String { choose("Favorite", "Favorita") }
    var advanced: String { choose("Advanced", "Avanzado") }
    var type: String { choose("Type", "Tipo") }
    var typeTOTP: String { choose("Time-based (TOTP)", "Por tiempo (TOTP)") }
    var typeHOTP: String { choose("Counter-based (HOTP)", "Por contador (HOTP)") }
    var typeSteam: String { choose("Steam Guard", "Steam Guard") }
    var algorithm: String { choose("Algorithm", "Algoritmo") }
    var digits: String { choose("Digits", "Dígitos") }
    var period: String { choose("Period (s)", "Periodo (s)") }
    var counter: String { choose("Counter", "Contador") }
    var save: String { choose("Save", "Guardar") }
    var cancel: String { choose("Cancel", "Cancelar") }
    var done: String { choose("Done", "Listo") }
    var uriLabel: String { choose("otpauth:// link", "Enlace otpauth://") }
    var uriHint: String {
        choose("Paste the link a service shows next to its QR code.", "Pega el enlace que el servicio muestra junto a su código QR.")
    }
    var uriUse: String { choose("Use link", "Usar enlace") }
    var uriInvalid: String { choose("That is not a valid otpauth:// link.", "Ese no es un enlace otpauth:// válido.") }
    var qrHint: String {
        choose("Scan a QR code from an image file or from anywhere on your screen.", "Escanea un código QR desde una imagen o desde cualquier parte de tu pantalla.")
    }
    var qrChooseImage: String { choose("Choose Image...", "Elegir imagen...") }
    var qrCaptureScreen: String { choose("Capture Screen Area", "Capturar área de pantalla") }
    var qrNotFound: String { choose("No QR code found in that image.", "No se encontró un código QR en esa imagen.") }
    var qrNotOTP: String { choose("That QR code is not a 2FA code.", "Ese código QR no es de 2FA.") }
    var qrLoaded: String { choose("QR code read. Review the details and save.", "QR leído. Revisa los datos y guarda.") }
    var duplicateAccount: String { choose("This account already exists.", "Esta cuenta ya existe.") }

    // MARK: Folders
    var foldersTitle: String { choose("Folders", "Carpetas") }
    var newFolder: String { choose("New folder", "Nueva carpeta") }
    var newFolderPlaceholder: String { choose("Folder name", "Nombre de la carpeta") }
    var noFolders: String { choose("No folders yet.", "Aún no hay carpetas.") }

    // MARK: Delete / alerts
    var deleteTitle: String { choose("Delete this account?", "¿Eliminar esta cuenta?") }
    var deleteMessage: String {
        choose("You may lose access to the service if you have not saved another way to sign in. This cannot be undone.",
               "Podrías perder acceso al servicio si no tienes otra forma de iniciar sesión. No se puede deshacer.")
    }
    var ok: String { choose("OK", "Aceptar") }

    // MARK: Import
    var importTitle: String { choose("Import complete", "Importación completa") }
    func importSummary(added: Int, duplicates: Int, skipped: Int) -> String {
        choose("Added \(added). Already present \(duplicates). Skipped \(skipped) invalid.",
               "Agregadas \(added). Ya existentes \(duplicates). Omitidas \(skipped) inválidas.")
    }
    var importFailed: String { choose("This file is not a LastPass Authenticator backup.", "Este archivo no es un respaldo de LastPass Authenticator.") }
    var importPanelMessage: String { choose("Choose the JSON backup exported from LastPass Authenticator.", "Elige el respaldo JSON exportado de LastPass Authenticator.") }

    // MARK: Lock
    var lockedTitle: String { choose("2FA-vlv is locked", "2FA-vlv está bloqueado") }
    var unlock: String { choose("Unlock", "Desbloquear") }
    var unlockReason: String { choose("Unlock your 2FA codes", "Desbloquear tus códigos 2FA") }
    var unlockFailed: String { choose("Authentication failed. Try again.", "Falló la autenticación. Intenta de nuevo.") }

    // MARK: Settings
    var general: String { choose("General", "General") }
    var security: String { choose("Security", "Seguridad") }
    var data: String { choose("Data", "Datos") }
    var aboutTab: String { choose("About", "Acerca de") }
    var languageLabel: String { choose("Language", "Idioma") }
    var appearanceSection: String { choose("Display", "Pantalla") }
    var systemSection: String { choose("System", "Sistema") }
    var hideCodes: String { choose("Hide codes until clicked", "Ocultar códigos hasta hacer clic") }
    var hideCodesHelp: String { choose("Codes stay masked for a few seconds after you click.", "Los códigos se muestran solo unos segundos tras hacer clic.") }
    var showMenuBarIcon: String { choose("Show menu bar icon", "Mostrar ícono en la barra de menú") }
    var globalHotKey: String { choose("Global shortcut ⌃⌥⌘2 to show/hide", "Atajo global ⌃⌥⌘2 para mostrar/ocultar") }
    var launchAtLogin: String { choose("Launch at login", "Abrir al iniciar sesión") }
    var launchAtLoginFailed: String { choose("Could not change the login item. Check System Settings > General > Login Items.", "No se pudo cambiar el elemento de inicio. Revisa Ajustes del Sistema > General > Ítems de inicio.") }
    var useKeychain: String { choose("Store secrets in the macOS Keychain", "Guardar secretos en el Llavero de macOS") }
    var useKeychainHelp: String {
        choose("Off: secrets are stored in the vault file (permissions 0600). Macs may ask for Keychain access after each app update.",
               "Apagado: los secretos se guardan en el archivo (permisos 0600). macOS puede pedir acceso al Llavero tras cada actualización.")
    }
    var keychainFallback: String { choose("Keychain unavailable. Secrets were saved in the vault file instead.", "Llavero no disponible. Los secretos se guardaron en el archivo.") }
    var requireAuth: String { choose("Require Touch ID or password to open", "Pedir Touch ID o contraseña para abrir") }
    var autoLock: String { choose("Auto-lock after", "Bloquear automáticamente tras") }
    var never: String { choose("Never", "Nunca") }
    func minutes(_ n: Int) -> String { choose(n == 1 ? "1 minute" : "\(n) minutes", n == 1 ? "1 minuto" : "\(n) minutos") }
    var clearClipboard: String { choose("Clear clipboard after copying a code", "Limpiar portapapeles tras copiar un código") }
    func seconds(_ n: Int) -> String { choose("\(n) seconds", "\(n) segundos") }
    var clearAfter: String { choose("Clear after", "Limpiar tras") }
    var importSection: String { choose("Import", "Importar") }
    var importHelp: String { choose("Bring accounts from a LastPass Authenticator JSON backup. Duplicates are skipped.", "Trae cuentas de un respaldo JSON de LastPass Authenticator. Los duplicados se omiten.") }
    var vaultSection: String { choose("Vault file", "Archivo de datos") }
    var revealVault: String { choose("Show in Finder", "Mostrar en Finder") }

    // MARK: About
    var version: String { choose("Version", "Versión") }
    var createdBy: String { choose("Created by VlV", "Creado por VlV") }
    var developerGitHub: String { choose("GitHub Profile", "Perfil de GitHub") }
    var projectGitHub: String { choose("Project on GitHub", "Proyecto en GitHub") }
    var projectSourceForge: String { choose("Project on SourceForge", "Proyecto en SourceForge") }
    var releases: String { choose("Releases", "Versiones publicadas") }
    var license: String { choose("MIT License", "Licencia MIT") }
    var tagline: String { choose("Simple, open-source two-factor codes.", "Códigos de dos factores, simples y de código abierto.") }
    var copyright: String { choose("Copyright © 2026 VlV. Released under the MIT License.", "Copyright © 2026 VlV. Publicado bajo Licencia MIT.") }
}
