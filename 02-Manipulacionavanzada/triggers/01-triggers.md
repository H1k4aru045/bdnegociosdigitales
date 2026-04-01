
# Triggers en SQL Server

## 1.¿Que es un Trigger

Un trigger (disparador) es un bloque de codigo SQL que se ejecuta automaticamente
cuando ocurre un evento en una tabla.

- Eventos principales
    - INSERT
    - UPDATE
    - DELETE

Nota: No se ejecutan manualmente, se activan solos

## 2. Para que sirven
    - Validaciones
    - Auditorias (Guardar historial)
    - Automatizacion

## 3. Tipos de Triggers en SQL Server

    - AFTER TRIGGER
    Se ejecuta despues del evento

    - INSTEAD OF TRIGGER
    Remplaza la operacion original

    ``` sql
    CREATE OR ALTER TRIGGER nombre_trigger
    ON nombre_tabla
    AFTER INSERT
    AS
    BEGIN
    END;
    ```

| Columna A | Columna B |
| :--- | :--- |
| Dato 1 | Detalle 1 |
| Dato 2 | Detalle 2 |
| Dato 3 | Detalle 3 |
