select TasaDolar as dolar,
TasaEuro as euro,
TasaCOP as cop
from KLK_PARAMETRIZACION
where FechaModificacionTasa > @FechaModificacion