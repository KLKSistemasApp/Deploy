SELECT RCL.NroRecibo AS rcl_id, CL.NFactura AS NumFactura, PC.IdFPagoSAP AS journal_id, PC.IdFPagoSAP AS journal_code, 
     --CL.MontoUsd AS amount, -- query en usd
    CL.Monto AS amount,  -- query en bs
    CL.FormadePago, CL.NTransaccion, CL.TarjetaCredito,
    CASE WHEN CL.FormadePago = 'Pago Nota de crédito' THEN 1 ELSE 0 END AS es_nota_credito
FROM KLK_RECIBOCOBROLINE RCL WITH (NOLOCK)
join KLK_COBROLINE CL on RCL.NroCobro = CL.NroCobro and CL.Monto = RCL.TotalAbonado
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
WHERE RCL.EnviadoASAP = 0;