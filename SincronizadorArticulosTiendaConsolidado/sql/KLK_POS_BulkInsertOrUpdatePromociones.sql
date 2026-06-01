CREATE OR ALTER PROCEDURE [dbo].[KLK_POS_BulkInsertOrUpdatePromociones]
    @json NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- 1. KLK_PROMOCIONHDR
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCIONHDR
    FROM OPENJSON(@json, '$.KLK_PROMOCIONHDR')
    WITH (
        Codigo                          NVARCHAR(30),
        Descripcion                     NVARCHAR(400),
        MensajePromo                    NVARCHAR(400),
        Estatus                         BIT,
        FechaInicio                     DATE,
        FechaFin                        DATE,
        HoraInicio                      DATETIME,
        HoraFin                         DATETIME,
        Lunes                           BIT,
        Martes                          BIT,
        Miercoles                       BIT,
        Jueves                          BIT,
        Viernes                         BIT,
        Sabado                          BIT,
        Domingo                         BIT,
        CodTipoPromo                    NVARCHAR(100),
        PorGrupo                        BIT,
        PorArticuloSeleccionado         BIT,
        EntrePrecios                    BIT,
        PrecioMin                       DECIMAL(19,6),
        PrecioMax                       DECIMAL(19,6),
        CantidadVenta1                  DECIMAL(19,6),
        CantidadPagar1                  DECIMAL(19,6),
        PorcDescuento1                  DECIMAL(19,6),
        PrecioPagar1                    DECIMAL(19,6),
        FechaCreacion                   DATE,
        FechaModificacion               DATE,
        Usuario                         NVARCHAR(100),
        PorExistencia                   BIT,
        PorExistenciaStockTotal         BIT,
        ListasPrecios                   NVARCHAR(200),
        CodGrupoPromo                   NVARCHAR(100),
        SoloaListasPrecio               BIT,
        TipoCondAplicar                 NVARCHAR(2),
        SoloClientesFidelizados         BIT,
        CantidadListaPrecio             DECIMAL(19,6),
        CodigoListaPrecio               NVARCHAR(100),
        SoloFidelizacionListadas        BIT,
        ListaCodFidelizacion            NVARCHAR(1000),
        ListaTipoCliente                NVARCHAR(1000),
        ListaFormasDePago               NVARCHAR(2000),
        PorCumpleano                    BIT,
        PeriodoValidesCumpleano         NVARCHAR(2),
        IntervaloDiasAntesCumpleano     INT,
        IntervaloDiasDespuesCumpleano   INT
    );

    -- ============================================================
    -- 2. KLK_PROMOCIONLINE
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCIONLINE
    FROM OPENJSON(@json, '$.KLK_PROMOCIONLINE')
    WITH (
        Codigo          NVARCHAR(30),
        NroLinea        INT,
        CantidadVenta   NVARCHAR(200),
        CantidadPagar   DECIMAL(19,6),
        PorcDescuento   DECIMAL(19,6),
        PrecioPagar     DECIMAL(19,6)
    );

    -- ============================================================
    -- 3. KLK_PROMOCIONGRUPOHDR
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCIONGRUPOHDR
    FROM OPENJSON(@json, '$.KLK_PROMOCIONGRUPOHDR')
    WITH (
        CodGrupoPromo               NVARCHAR(30),
        NombreGrupo                 NVARCHAR(400),
        CodGrupoArticulo            NVARCHAR(100),
        CodSubGrupoArticulo         NVARCHAR(100),
        CodMarca                    NVARCHAR(100),
        CodDepartamento             NVARCHAR(100),
        CodCategoria                NVARCHAR(100),
        CodComposicion              NVARCHAR(100),
        SoloArticuloSelecionados    BIT
    );

    -- ============================================================
    -- 4. KLK_PROMOCIONGRUPOLINE
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCIONGRUPOLINE
    FROM OPENJSON(@json, '$.KLK_PROMOCIONGRUPOLINE')
    WITH (
        CodGrupoPromo   NVARCHAR(30),
        CodArticulo     NVARCHAR(100),
        TipoAccion      NVARCHAR(2)
    );

    -- ============================================================
    -- 5. KLK_PROMOCIONTIPO
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCIONTIPO
    FROM OPENJSON(@json, '$.KLK_PROMOCIONTIPO')
    WITH (
        Codigo          NVARCHAR(30),
        Descripcion     NVARCHAR(400),
        Activo          BIT
    );

    -- ============================================================
    -- 6. KLK_PROMOCION_PARAMETRIZACION
    -- ============================================================
    SELECT *
    INTO #TMP_PROMOCION_PARAMETRIZACION
    FROM OPENJSON(@json, '$.KLK_PROMOCION_PARAMETRIZACION')
    WITH (
        Id                  INT,
        OrdenTomarPromo     NVARCHAR(4)
    );

    -- ============================================================
    -- MERGE: KLK_PROMOCIONTIPO
    -- ============================================================
    MERGE KLK_PROMOCIONTIPO AS DESTINO
    USING #TMP_PROMOCIONTIPO AS ORIGEN
        ON DESTINO.Codigo = ORIGEN.Codigo
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.Descripcion = ORIGEN.Descripcion,
            DESTINO.Activo      = ORIGEN.Activo
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Codigo, Descripcion, Activo)
        VALUES (ORIGEN.Codigo, ORIGEN.Descripcion, ORIGEN.Activo);

    -- ============================================================
    -- MERGE: KLK_PROMOCIONGRUPOHDR
    -- ============================================================
    MERGE KLK_PROMOCIONGRUPOHDR AS DESTINO
    USING #TMP_PROMOCIONGRUPOHDR AS ORIGEN
        ON DESTINO.CodGrupoPromo = ORIGEN.CodGrupoPromo
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.NombreGrupo              = ORIGEN.NombreGrupo,
            DESTINO.CodGrupoArticulo         = ORIGEN.CodGrupoArticulo,
            DESTINO.CodSubGrupoArticulo      = ORIGEN.CodSubGrupoArticulo,
            DESTINO.CodMarca                 = ORIGEN.CodMarca,
            DESTINO.CodDepartamento          = ORIGEN.CodDepartamento,
            DESTINO.CodCategoria             = ORIGEN.CodCategoria,
            DESTINO.CodComposicion           = ORIGEN.CodComposicion,
            DESTINO.SoloArticuloSelecionados = ORIGEN.SoloArticuloSelecionados
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            CodGrupoPromo, NombreGrupo, CodGrupoArticulo, CodSubGrupoArticulo,
            CodMarca, CodDepartamento, CodCategoria, CodComposicion, SoloArticuloSelecionados
        )
        VALUES (
            ORIGEN.CodGrupoPromo, ORIGEN.NombreGrupo, ORIGEN.CodGrupoArticulo, ORIGEN.CodSubGrupoArticulo,
            ORIGEN.CodMarca, ORIGEN.CodDepartamento, ORIGEN.CodCategoria, ORIGEN.CodComposicion, ORIGEN.SoloArticuloSelecionados
        );

    -- ============================================================
    -- MERGE: KLK_PROMOCIONGRUPOLINE
    -- Clave: CodGrupoPromo + CodArticulo
    -- Elimina líneas huérfanas solo de grupos presentes en el lote
    -- ============================================================
    MERGE KLK_PROMOCIONGRUPOLINE AS DESTINO
    USING #TMP_PROMOCIONGRUPOLINE AS ORIGEN
        ON  DESTINO.CodGrupoPromo = ORIGEN.CodGrupoPromo
        AND DESTINO.CodArticulo   = ORIGEN.CodArticulo
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.TipoAccion = ORIGEN.TipoAccion
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CodGrupoPromo, CodArticulo, TipoAccion)
        VALUES (ORIGEN.CodGrupoPromo, ORIGEN.CodArticulo, ORIGEN.TipoAccion)
    WHEN NOT MATCHED BY SOURCE
        AND DESTINO.CodGrupoPromo IN (SELECT CodGrupoPromo FROM #TMP_PROMOCIONGRUPOHDR) THEN
        DELETE;

    -- ============================================================
    -- MERGE: KLK_PROMOCIONHDR
    -- ============================================================
    MERGE KLK_PROMOCIONHDR AS DESTINO
    USING #TMP_PROMOCIONHDR AS ORIGEN
        ON DESTINO.Codigo = ORIGEN.Codigo
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.Descripcion                     = ORIGEN.Descripcion,
            DESTINO.MensajePromo                    = ORIGEN.MensajePromo,
            DESTINO.Estatus                         = ORIGEN.Estatus,
            DESTINO.FechaInicio                     = ORIGEN.FechaInicio,
            DESTINO.FechaFin                        = ORIGEN.FechaFin,
            DESTINO.HoraInicio                      = ORIGEN.HoraInicio,
            DESTINO.HoraFin                         = ORIGEN.HoraFin,
            DESTINO.Lunes                           = ORIGEN.Lunes,
            DESTINO.Martes                          = ORIGEN.Martes,
            DESTINO.Miercoles                       = ORIGEN.Miercoles,
            DESTINO.Jueves                          = ORIGEN.Jueves,
            DESTINO.Viernes                         = ORIGEN.Viernes,
            DESTINO.Sabado                          = ORIGEN.Sabado,
            DESTINO.Domingo                         = ORIGEN.Domingo,
            DESTINO.CodTipoPromo                    = ORIGEN.CodTipoPromo,
            DESTINO.PorGrupo                        = ORIGEN.PorGrupo,
            DESTINO.PorArticuloSeleccionado         = ORIGEN.PorArticuloSeleccionado,
            DESTINO.EntrePrecios                    = ORIGEN.EntrePrecios,
            DESTINO.PrecioMin                       = ORIGEN.PrecioMin,
            DESTINO.PrecioMax                       = ORIGEN.PrecioMax,
            DESTINO.CantidadVenta1                  = ORIGEN.CantidadVenta1,
            DESTINO.CantidadPagar1                  = ORIGEN.CantidadPagar1,
            DESTINO.PorcDescuento1                  = ORIGEN.PorcDescuento1,
            DESTINO.PrecioPagar1                    = ORIGEN.PrecioPagar1,
            DESTINO.FechaCreacion                   = ORIGEN.FechaCreacion,
            DESTINO.FechaModificacion               = ORIGEN.FechaModificacion,
            DESTINO.Usuario                         = ORIGEN.Usuario,
            DESTINO.PorExistencia                   = ORIGEN.PorExistencia,
            DESTINO.PorExistenciaStockTotal         = ORIGEN.PorExistenciaStockTotal,
            DESTINO.ListasPrecios                   = ORIGEN.ListasPrecios,
            DESTINO.CodGrupoPromo                   = ORIGEN.CodGrupoPromo,
            DESTINO.SoloaListasPrecio               = ORIGEN.SoloaListasPrecio,
            DESTINO.TipoCondAplicar                 = ORIGEN.TipoCondAplicar,
            DESTINO.SoloClientesFidelizados         = ORIGEN.SoloClientesFidelizados,
            DESTINO.CantidadListaPrecio             = ORIGEN.CantidadListaPrecio,
            DESTINO.CodigoListaPrecio               = ORIGEN.CodigoListaPrecio,
            DESTINO.SoloFidelizacionListadas        = ORIGEN.SoloFidelizacionListadas,
            DESTINO.ListaCodFidelizacion            = ORIGEN.ListaCodFidelizacion,
            DESTINO.ListaTipoCliente                = ORIGEN.ListaTipoCliente,
            DESTINO.ListaFormasDePago               = ORIGEN.ListaFormasDePago,
            DESTINO.PorCumpleano                    = ORIGEN.PorCumpleano,
            DESTINO.PeriodoValidesCumpleano         = ORIGEN.PeriodoValidesCumpleano,
            DESTINO.IntervaloDiasAntesCumpleano     = ORIGEN.IntervaloDiasAntesCumpleano,
            DESTINO.IntervaloDiasDespuesCumpleano   = ORIGEN.IntervaloDiasDespuesCumpleano
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Codigo, Descripcion, MensajePromo, Estatus,
            FechaInicio, FechaFin, HoraInicio, HoraFin,
            Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo,
            CodTipoPromo, PorGrupo, PorArticuloSeleccionado, EntrePrecios,
            PrecioMin, PrecioMax,
            CantidadVenta1, CantidadPagar1, PorcDescuento1, PrecioPagar1,
            FechaCreacion, FechaModificacion, Usuario,
            PorExistencia, PorExistenciaStockTotal,
            ListasPrecios, CodGrupoPromo, SoloaListasPrecio, TipoCondAplicar,
            SoloClientesFidelizados, CantidadListaPrecio, CodigoListaPrecio,
            SoloFidelizacionListadas, ListaCodFidelizacion, ListaTipoCliente, ListaFormasDePago,
            PorCumpleano, PeriodoValidesCumpleano,
            IntervaloDiasAntesCumpleano, IntervaloDiasDespuesCumpleano
        )
        VALUES (
            ORIGEN.Codigo, ORIGEN.Descripcion, ORIGEN.MensajePromo, ORIGEN.Estatus,
            ORIGEN.FechaInicio, ORIGEN.FechaFin, ORIGEN.HoraInicio, ORIGEN.HoraFin,
            ORIGEN.Lunes, ORIGEN.Martes, ORIGEN.Miercoles, ORIGEN.Jueves,
            ORIGEN.Viernes, ORIGEN.Sabado, ORIGEN.Domingo,
            ORIGEN.CodTipoPromo, ORIGEN.PorGrupo, ORIGEN.PorArticuloSeleccionado, ORIGEN.EntrePrecios,
            ORIGEN.PrecioMin, ORIGEN.PrecioMax,
            ORIGEN.CantidadVenta1, ORIGEN.CantidadPagar1, ORIGEN.PorcDescuento1, ORIGEN.PrecioPagar1,
            ORIGEN.FechaCreacion, ORIGEN.FechaModificacion, ORIGEN.Usuario,
            ORIGEN.PorExistencia, ORIGEN.PorExistenciaStockTotal,
            ORIGEN.ListasPrecios, ORIGEN.CodGrupoPromo, ORIGEN.SoloaListasPrecio, ORIGEN.TipoCondAplicar,
            ORIGEN.SoloClientesFidelizados, ORIGEN.CantidadListaPrecio, ORIGEN.CodigoListaPrecio,
            ORIGEN.SoloFidelizacionListadas, ORIGEN.ListaCodFidelizacion, ORIGEN.ListaTipoCliente,
            ORIGEN.ListaFormasDePago, ORIGEN.PorCumpleano, ORIGEN.PeriodoValidesCumpleano,
            ORIGEN.IntervaloDiasAntesCumpleano, ORIGEN.IntervaloDiasDespuesCumpleano
        );

    -- ============================================================
    -- MERGE: KLK_PROMOCIONLINE
    -- Clave: Codigo + NroLinea
    -- Elimina líneas huérfanas solo de cabeceras presentes en el lote
    -- ============================================================
    MERGE KLK_PROMOCIONLINE AS DESTINO
    USING #TMP_PROMOCIONLINE AS ORIGEN
        ON  DESTINO.Codigo   = ORIGEN.Codigo
        AND DESTINO.NroLinea = ORIGEN.NroLinea
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.CantidadVenta = ORIGEN.CantidadVenta,
            DESTINO.CantidadPagar = ORIGEN.CantidadPagar,
            DESTINO.PorcDescuento = ORIGEN.PorcDescuento,
            DESTINO.PrecioPagar   = ORIGEN.PrecioPagar
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Codigo, NroLinea, CantidadVenta, CantidadPagar, PorcDescuento, PrecioPagar)
        VALUES (ORIGEN.Codigo, ORIGEN.NroLinea, ORIGEN.CantidadVenta, ORIGEN.CantidadPagar,
                ORIGEN.PorcDescuento, ORIGEN.PrecioPagar)
    WHEN NOT MATCHED BY SOURCE
        AND DESTINO.Codigo IN (SELECT Codigo FROM #TMP_PROMOCIONHDR) THEN
        DELETE;

    -- ============================================================
    -- MERGE: KLK_PROMOCION_PARAMETRIZACION
    -- Clave: Id (registro único de configuración global)
    -- ============================================================
    MERGE KLK_PROMOCION_PARAMETRIZACION AS DESTINO
    USING #TMP_PROMOCION_PARAMETRIZACION AS ORIGEN
        ON DESTINO.Id = ORIGEN.Id
    WHEN MATCHED THEN
        UPDATE SET
            DESTINO.OrdenTomarPromo = ORIGEN.OrdenTomarPromo
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Id, OrdenTomarPromo)
        VALUES (ORIGEN.Id, ORIGEN.OrdenTomarPromo);

    -- Limpieza de temporales
    DROP TABLE IF EXISTS #TMP_PROMOCIONHDR;
    DROP TABLE IF EXISTS #TMP_PROMOCIONLINE;
    DROP TABLE IF EXISTS #TMP_PROMOCIONGRUPOHDR;
    DROP TABLE IF EXISTS #TMP_PROMOCIONGRUPOLINE;
    DROP TABLE IF EXISTS #TMP_PROMOCIONTIPO;
    DROP TABLE IF EXISTS #TMP_PROMOCION_PARAMETRIZACION;

END;
