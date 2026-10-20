# Sauce Demo – Automatización E2E con Playwright, Cucumber y TypeScript

Suite de pruebas automatizadas para la aplicación web [Sauce Demo](https://www.saucedemo.com/), desarrollada con **Playwright**, **Cucumber (Gherkin)** y **TypeScript**, aplicando el patrón **Page Object Model**.

## Historia de usuario

> **Como** un cliente de Sauce Demo,
> **quiero** poder iniciar sesión, agregar productos al carrito y completar una compra,
> **para** poder adquirir los productos que necesito.

## Stack tecnológico

| Herramienta | Uso |
|---|---|
| [Playwright](https://playwright.dev/) | Librería de automatización del navegador |
| [Cucumber.js](https://github.com/cucumber/cucumber-js) | Runner BDD y ejecución de escenarios Gherkin |
| TypeScript 5 | Lenguaje con tipado estático |
| ts-node | Ejecución directa de TypeScript sin compilación previa |
| `@playwright/test` (`expect`) | Aserciones web-first con reintento automático |

## Requisitos previos

- [Node.js](https://nodejs.org/) versión LTS (18 o superior)
- npm (incluido con Node.js)
- Git

Verifica la instalación:

```bash
node -v
npm -v
```

## Instalación

```bash
git clone https://github.com/markaguirrel/saucedemo-playwright-cucumber.git
cd saucedemo-playwright-cucumber
npm install
npx playwright install chromium
```

## Ejecución de pruebas

| Comando | Descripción |
|---|---|
| `npm test` | Ejecuta todos los escenarios en modo headless |
| `npm run test:headed` | Ejecuta mostrando el navegador |
| `npm run test:smoke` | Ejecuta solo los escenarios con tag `@smoke` |
| `npm test -- --tags @login` | Ejecuta solo los escenarios de login |
| `npm test -- --tags "@login and @negative"` | Combina tags (`and`, `or`, `not`) |

### Variables de entorno

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `HEADLESS` | `true` | Con `false` se muestra el navegador |
| `BASE_URL` | `https://www.saucedemo.com` | URL del ambiente bajo prueba |

Ejemplo:

```bash
BASE_URL=https://www.saucedemo.com HEADLESS=false npm test
```

## Reporte

Al finalizar cada ejecución se genera un reporte HTML en:

```
reports/cucumber-report.html
```

En macOS puede abrirse con `open reports/cucumber-report.html`. Si un escenario falla, el reporte incluye una **captura de pantalla** de la página en el momento del fallo.

## Estructura del proyecto

```
├── features/                 # Escenarios en Gherkin
│   ├── login.feature
│   └── purchase.feature
├── src/
│   ├── pages/                # Page Objects
│   ├── steps/                # Step definitions
│   ├── support/              # World (contexto por escenario) y hooks
│   └── utils/                # Configuración y datos de prueba
├── cucumber.js               # Configuración de Cucumber
├── tsconfig.json             # Configuración de TypeScript
└── package.json
```

## Cobertura de criterios de aceptación

| # | Criterio de aceptación | Escenario(s) | Tags |
|---|---|---|---|
| 1 | Iniciar sesión con credenciales válidas | Inicio de sesión exitoso con usuario estándar | `@login @smoke` |
| 2 | No iniciar sesión con credenciales inválidas | Usuario bloqueado no puede iniciar sesión · Inicio de sesión fallido con credenciales inválidas (4 casos) | `@login @negative` |
| 3 | Agregar un producto al carrito | Agregar un producto al carrito desde la página de productos | `@purchase @smoke` |
| 4 | Ver los productos agregados en el carrito | Visualizar los productos agregados en el carrito | `@purchase @cart` |
| 5 | Completar la compra hasta la confirmación | Completar el proceso de compra hasta la confirmación | `@purchase @e2e` |

Usuarios cubiertos: `standard_user` y `locked_out_user`.

## Documentación adicional

- [Estrategia de automatización y patrones utilizados](ESTRATEGIA.md)

## Autor

Mark Aguirre
