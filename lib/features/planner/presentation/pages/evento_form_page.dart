import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/evento.dart';
import '../../domain/usecases/listar_categorias.dart';
import '../bloc/evento_bloc.dart';
import '../bloc/evento_event.dart';
import '../bloc/evento_state.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

/// Formulario para crear o editar un evento de la agenda.
///
/// Recibe el [EventoBloc] de la pantalla que lo abre para reutilizar la misma
/// instancia (la ruta nueva no es descendiente del `BlocProvider` del home).
class EventoFormPage extends StatelessWidget {
  const EventoFormPage({
    super.key,
    required this.bloc,
    required this.listarCategorias,
    this.evento,
  });

  final EventoBloc bloc;
  final ListarCategorias listarCategorias;

  /// Evento a editar; `null` cuando se crea uno nuevo.
  final Evento? evento;

  @override
  Widget build(BuildContext context) {
    return _EventoFormView(
      bloc: bloc,
      listarCategorias: listarCategorias,
      evento: evento,
    );
  }
}

class _EventoFormView extends StatefulWidget {
  const _EventoFormView({
    required this.bloc,
    required this.listarCategorias,
    this.evento,
  });

  final EventoBloc bloc;
  final ListarCategorias listarCategorias;
  final Evento? evento;

  @override
  State<_EventoFormView> createState() => _EventoFormViewState();
}

class _EventoFormViewState extends State<_EventoFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late final TextEditingController _ubicacion;

  late DateTime _inicio;
  late DateTime _fin;
  int? _categoriaSeleccionada;

  List<Categoria> _categorias = const <Categoria>[];
  bool _cargandoCategorias = true;
  String? _errorCategorias;
  String? _errorFechas;
  bool _enviando = false;
  bool _finalizado = false;

  bool get _esEdicion => widget.evento != null;

  @override
  void initState() {
    super.initState();
    final evento = widget.evento;
    _titulo = TextEditingController(text: evento?.titulo ?? '');
    _descripcion = TextEditingController(text: evento?.descripcion ?? '');
    _ubicacion = TextEditingController(text: evento?.ubicacion ?? '');

    final ahora = DateTime.now();
    final inicioSugerido = DateTime(
      ahora.year,
      ahora.month,
      ahora.day,
      ahora.hour + 1,
    );
    _inicio = evento == null ? inicioSugerido : evento.fechaInicio.toLocal();
    _fin = evento == null
        ? inicioSugerido.add(const Duration(hours: 1))
        : evento.fechaFin.toLocal();
    _categoriaSeleccionada = evento?.categoriaId;

    _cargarCategorias();
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    if (!_cargandoCategorias) {
      setState(() {
        _cargandoCategorias = true;
        _errorCategorias = null;
      });
    }
    try {
      final categorias = await widget.listarCategorias(
        usuarioId: widget.bloc.usuarioId,
      );
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        _cargandoCategorias = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoCategorias = false;
        _errorCategorias = mensajeError(error);
      });
    }
  }

  Future<void> _seleccionarInicio() {
    return _seleccionarFechaHora(
      valor: _inicio,
      alSeleccionar: (fecha) {
        setState(() {
          _inicio = fecha;
          if (_fin.isBefore(fecha)) {
            _fin = fecha.add(const Duration(hours: 1));
          }
          _errorFechas = null;
        });
      },
    );
  }

  Future<void> _seleccionarFin() {
    return _seleccionarFechaHora(
      valor: _fin,
      alSeleccionar: (fecha) {
        setState(() {
          _fin = fecha;
          _errorFechas = null;
        });
      },
    );
  }

  Future<void> _seleccionarFechaHora({
    required DateTime valor,
    required ValueChanged<DateTime> alSeleccionar,
  }) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: valor,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(valor),
      helpText: 'Selecciona la hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (hora == null || !mounted) return;

    alSeleccionar(
      DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute),
    );
  }

  void _guardar() {
    FocusScope.of(context).unfocus();

    final formularioValido = _formKey.currentState?.validate() ?? false;
    final errorFechas = Validators.rangoFechas(_inicio, _fin);
    setState(() => _errorFechas = errorFechas);
    if (!formularioValido || errorFechas != null) return;

    final original = widget.evento;
    final evento = Evento(
      id: original?.id,
      usuarioId: original?.usuarioId ?? widget.bloc.usuarioId,
      categoriaId: _categoriaSeleccionada,
      titulo: _titulo.text.trim(),
      descripcion: _textoOpcional(_descripcion.text),
      ubicacion: _textoOpcional(_ubicacion.text),
      fechaInicio: _inicio,
      fechaFin: _fin,
      createdAt: original?.createdAt,
      updatedAt: original?.updatedAt,
    );

    setState(() => _enviando = true);
    widget.bloc.add(
      original == null
          ? CrearEventoSolicitado(evento)
          : ActualizarEventoSolicitado(evento),
    );
  }

  String? _textoOpcional(String valor) {
    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }

  void _finalizarConExito(String mensaje) {
    if (_finalizado) return;
    _finalizado = true;
    Navigator.of(context).pop(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventoBloc, EventoState>(
      bloc: widget.bloc,
      listenWhen: (_, actual) =>
          (actual is EventoOperacionExitosa &&
              actual.origen == EventoOrigenOperacion.formulario) ||
          (actual is EventoOperacionFallida &&
              actual.origen == EventoOrigenOperacion.formulario),
      listener: (context, state) {
        switch (state) {
          case EventoOperacionExitosa(:final mensaje):
            _finalizarConExito(mensaje);
            break;
          case EventoOperacionFallida(:final mensaje):
            if (!mounted) return;
            setState(() => _enviando = false);
            AppSnackBar.error(context, mensaje);
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_esEdicion ? 'Editar evento' : 'Nuevo evento'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const _TituloSeccion(
                icono: Icons.edit_note_outlined,
                titulo: 'Detalles del evento',
              ),
              const SizedBox(height: 12),
              CustomInput(
                controller: _titulo,
                label: 'Título',
                hint: 'Ej. Reunión de equipo',
                prefixIcon: Icons.title,
                validator: Validators.titulo,
                maxLength: 150,
                textInputAction: TextInputAction.next,
                enabled: !_enviando,
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: _descripcion,
                label: 'Descripción',
                hint: 'Describe el objetivo del evento (opcional)',
                prefixIcon: Icons.notes_outlined,
                validator: Validators.descripcion,
                maxLength: 1000,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                enabled: !_enviando,
              ),
              const SizedBox(height: 8),
              CustomInput(
                controller: _ubicacion,
                label: 'Ubicación',
                hint: 'Ej. Sala 2, bloque B (opcional)',
                prefixIcon: Icons.place_outlined,
                validator: Validators.ubicacion,
                maxLength: 200,
                textInputAction: TextInputAction.done,
                enabled: !_enviando,
              ),

              const SizedBox(height: 16),
              const _TituloSeccion(
                icono: Icons.schedule_outlined,
                titulo: 'Fecha y hora',
              ),
              const SizedBox(height: 12),
              _SelectorFechaHora(
                label: 'Inicio',
                valor: _inicio,
                onTap: _enviando ? null : _seleccionarInicio,
              ),
              const SizedBox(height: 12),
              _SelectorFechaHora(
                label: 'Fin',
                valor: _fin,
                onTap: _enviando ? null : _seleccionarFin,
              ),
              if (_errorFechas != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorFechas!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const _TituloSeccion(
                icono: Icons.label_outline,
                titulo: 'Categoría',
              ),
              const SizedBox(height: 12),
              _construirCategorias(context),
              const SizedBox(height: 24),
              BlocBuilder<EventoBloc, EventoState>(
                bloc: widget.bloc,
                builder: (context, state) {
                  final guardando =
                      _enviando || state is EventoOperacionEnCurso;
                  return CustomButton(
                    label: _esEdicion ? 'Guardar cambios' : 'Crear evento',
                    icon: _esEdicion ? Icons.save_outlined : Icons.add,
                    cargando: guardando,
                    onPressed: guardando ? null : _guardar,
                  );
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Cancelar',
                variante: CustomButtonVariant.texto,
                onPressed: _enviando
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCategorias(BuildContext context) {
    if (_cargandoCategorias) {
      return const LinearProgressIndicator();
    }

    final error = _errorCategorias;
    if (error != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'No se pudieron cargar las categorías: $error',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: _cargarCategorias,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CategoryChip(
              key: const ValueKey('categoria-sin-asignar'),
              nombre: 'Sin categoría',
              icono: Icons.label_off_outlined,
              seleccionado: _categoriaSeleccionada == null,
              onTap: _enviando
                  ? null
                  : () => setState(() => _categoriaSeleccionada = null),
            ),
            for (final categoria in _categorias)
              if (categoria.id != null)
                CategoryChip(
                  key: ValueKey('categoria-${categoria.id}'),
                  nombre: categoria.nombre,
                  color: colorDesdeHex(categoria.colorHex),
                  seleccionado: _categoriaSeleccionada == categoria.id,
                  onTap: _enviando
                      ? null
                      : () => setState(
                          () => _categoriaSeleccionada = categoria.id,
                        ),
                ),
          ],
        ),
        if (_categorias.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Aún no tienes categorías. Puedes guardar el evento sin categoría.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.icono, required this.titulo});

  final IconData icono;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icono, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SelectorFechaHora extends StatelessWidget {
  const _SelectorFechaHora({
    required this.label,
    required this.valor,
    required this.onTap,
  });

  final String label;
  final DateTime valor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      key: ValueKey('fecha-$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormatters.formatearFechaHora(valor),
                style: textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.edit_calendar_outlined,
              size: 18,
              color: textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}
