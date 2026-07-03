# tukuntech

A new Flutter project.

## Running the Project with Different Environments

You can start the project targeting either the **Test** or **Prod** environments.

### 1. From the Command Line (CLI)

Use the `--dart-define=ENV=<env>` option:

*   **Test Environment** (runs against local backend at `localhost:8080` / `10.0.2.2:8080`):
    ```bash
    flutter run --dart-define=ENV=test
    ```
    *(If no option is provided, it defaults to the Test environment)*

*   **Prod Environment** (runs against production backend at `http://tukuntech-backend.duckdns.org/`):
    ```bash
    flutter run --dart-define=ENV=prod
    ```

### 2. From VS Code
Open the Run & Debug sidebar and select:
*   `Tukuntech (Test)`
*   `Tukuntech (Prod)`

### 3. From Android Studio / IntelliJ
Open the Run Configurations dropdown and select:
*   `main.dart (Test)`
*   `main.dart (Prod)`
