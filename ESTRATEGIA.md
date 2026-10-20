# Estrategia de automatización y patrones utilizados

## 1. Objetivo

Validar de forma automatizada el flujo principal de compra de Sauce Demo (inicio de sesión, gestión del carrito y checkout), cubriendo los cinco criterios de aceptación de la historia de usuario y los tipos de usuario `standard_user` y `locked_out_user`.

## 2. Enfoque

Se adoptó un enfoque **BDD (Behavior Driven Development)**:

- Los escenarios se describen en **Gherkin** con un estilo **declarativo**: expresan *qué* hace el usuario y no *cómo* interactúa con la interfaz. Los detalles técnicos (locators, clics) se encapsulan en los Page Objects.
- Las palabras clave de Gherkin están en inglés (estándar de la industria) y el texto de los pasos en español, para que la especificación sea legible por todo el equipo.
- Cada criterio de aceptación tiene al menos un escenario asociado (ver la tabla de trazabilidad en el README).

## 3. Selección de herramientas

| Herramienta | Justificación |
|---|---|
| **Playwright** | Espera automática (*auto-wait*) en cada acción, aserciones con reintento y gestión de navegadores sin drivers externos. Reduce la inestabilidad (*flakiness*) frente a esperas explícitas. |
| **Cucumber.js** | Actúa como runner y permite vincular la especificación Gherkin con el código. Playwright se usa como librería, no con su runner propio. |
| **TypeScript 5** | Tipado estático para detectar errores en tiempo de desarrollo y mejor autocompletado. Se fijó la versión 5 porque TypeScript 7 (compilador nativo reescrito en Go) aún no es compatible con la API que utiliza `ts-node`. |

## 4. Arquitectura en capas

```
Feature files (Gherkin)      → ¿Qué se prueba? (negocio)
        ↓
Step definitions             → Traducen pasos a acciones y aserciones
        ↓
Page Objects                 → ¿Cómo se interactúa con cada página?
        ↓
Playwright                   → Control del navegador
```

Cada capa tiene una única responsabilidad, lo que facilita el mantenimiento: un cambio en la interfaz solo afecta al Page Object correspondiente.

## 5. Patrones de diseño aplicados

### 5.1 Page Object Model (POM)

Se creó un Page Object por cada pantalla de la aplicación:

| Page Object | Página |
|---|---|
| `LoginPage` | `/` |
| `InventoryPage` | `/inventory.html` |
| `CartPage` | `/cart.html` |
| `CheckoutInfoPage` | `/checkout-step-one.html` |
| `CheckoutOverviewPage` | `/checkout-step-two.html` |
| `CheckoutCompletePage` | `/checkout-complete.html` |

Decisiones:

- Los locators de interacción son **privados**; solo se exponen los necesarios para validar.
- Los Page Objects contienen **acciones**, y las **aserciones** se realizan en los step definitions. Así los Page Objects son reutilizables en cualquier prueba sin acoplarse a una validación concreta.
- Los locators se definen en el constructor. Al ser perezosos (*lazy*), no buscan el elemento hasta que se ejecuta una acción, por lo que no se requiere un mecanismo como `PageFactory`.

### 5.2 World (contexto compartido por escenario)

El **World** de Cucumber (`CustomWorld`) se crea de nuevo en cada escenario y comparte el `BrowserContext` y la `Page` entre los steps. Cumple el rol de la inyección de dependencias del contexto de prueba.

### 5.3 Separación de datos y configuración

- **Datos de prueba** (`src/utils/users.ts`): las credenciales se centralizan y se obtienen por clave. Los escenarios que requieren un usuario autenticado solo indican el nombre del usuario.
- **Configuración** (`src/utils/config.ts`): la URL base y el modo headless se leen de variables de entorno con valores por defecto, lo que permite ejecutar contra otros ambientes sin modificar el código.

## 6. Estrategia de locators

Se priorizaron los atributos `data-test` que Sauce Demo expone para automatización, por ser independientes de estilos y textos. Se configuró `selectors.setTestIdAttribute('data-test')` para usar `getByTestId()`, lo que hace los Page Objects más legibles.

Para el botón de agregar al carrito se construye el locator dinámicamente a partir del nombre del producto, de modo que un solo método sirve para cualquier producto.

## 7. Diseño de los escenarios

- **Background** para las precondiciones comunes de cada feature.
- **Scenario Outline** para los casos de inicio de sesión fallido (contraseña incorrecta, usuario inexistente, usuario vacío y contraseña vacía).
- **Escenario dedicado para `locked_out_user`**, al ser un requisito explícito del reto.
- **Data Tables** para agregar y validar varios productos en el carrito.
- **Tags** (`@smoke`, `@login`, `@purchase`, `@negative`, `@cart`, `@e2e`, `@locked`) para ejecutar subconjuntos de pruebas.
- **Reutilización de steps:** 9 escenarios se implementan con 14 step definitions.

## 8. Aislamiento y rendimiento

- Se lanza **un solo navegador** por ejecución (`BeforeAll`).
- Cada escenario usa un **`BrowserContext` nuevo** (equivalente a una sesión de incógnito), lo que garantiza que no compartan cookies, sesión ni carrito, sin el costo de relanzar el navegador.
- Resultado: la suite completa se ejecuta en aproximadamente 5 segundos.

## 9. Evidencias y reporte

- Reporte HTML de Cucumber en `reports/cucumber-report.html`.
- Captura de pantalla automática de la página completa cuando un escenario falla, adjunta al reporte mediante el hook `After`.

## 10. Mejoras futuras

- Integración continua con **GitHub Actions** para ejecutar la suite en cada *push* o *pull request*.
- Ejecución en varios navegadores (Firefox y WebKit).
- Ejecución en paralelo con la opción `parallel` de Cucumber.
- Escenarios adicionales: eliminar productos del carrito, validaciones del formulario de checkout y cálculo del total.
- Linting y formato automático con ESLint y Prettier.
