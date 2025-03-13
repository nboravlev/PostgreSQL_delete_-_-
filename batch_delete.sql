DO $$

DECLARE
    _limit INT := 100000; 
    _deleted_rows INT;       
    _total_deleted_rows INT := 0;  

BEGIN
    LOOP
        -- Выбираем батч для удаления
        WITH batch AS (
            SELECT id
            FROM table_name
            WHERE created_at::date = '2023-07-31'
            LIMIT _limit
        ),
        del AS (
            DELETE FROM table_name gth
            USING batch
            WHERE gth.id = batch.id
            RETURNING gth.id
        )
        SELECT count(id) INTO _deleted_rows FROM del;

        _total_deleted_rows := _total_deleted_rows + _deleted_rows;

        -- Фиксируем изменения
        COMMIT;

        -- Если записей больше нет — выходим
        EXIT WHEN _deleted_rows = 0;
    END LOOP;

    -- Логируем результат
    RAISE NOTICE 'Всего удалено строк: %', _total_deleted_rows;
    RAISE NOTICE 'Актуальная дата самой старой записи: %', 
        (SELECT min(created_at) FROM table_name);

END $$;
