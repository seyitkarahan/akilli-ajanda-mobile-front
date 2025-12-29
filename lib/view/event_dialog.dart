import 'package:akilli_ajanda_front/view/map_screen.dart';
import 'package:akilli_ajanda_front/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../model/event_request.dart';
import '../model/event_response.dart';
import '../model/category_response.dart';
import '../service/api_service.dart';
import 'dart:ui';

class EventDialog extends StatelessWidget {
  final EventResponse? event;
  final DateTime? selectedDate;

  const EventDialog({super.key, this.event, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return _EventDialogContent(event: event, selectedDate: selectedDate);
  }
}

class _EventDialogContent extends StatefulWidget {
  final EventResponse? event;
  final DateTime? selectedDate;

  const _EventDialogContent({this.event, this.selectedDate});

  @override
  State<_EventDialogContent> createState() => _EventDialogContentState();
}

class _EventDialogContentState extends State<_EventDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  int? _categoryId;
  List<CategoryResponse> _categories = [];
  late DateTime _startTime;
  late DateTime _endTime;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _categoryId = widget.event?.categoryId;
    _startTime = widget.event?.startTime ?? widget.selectedDate ?? DateTime.now();
    _endTime = widget.event?.endTime ?? (widget.selectedDate ?? DateTime.now()).add(const Duration(hours: 1));
    if (widget.event?.latitude != null && widget.event?.longitude != null) {
      _selectedLocation = LatLng(widget.event!.latitude!, widget.event!.longitude!);
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final categories = await ApiService().getCategories();
    setState(() {
      _categories = categories;
      if (_categoryId == null && _categories.length == 1) {
        _categoryId = _categories.first.id;
      }
    });
  }

  Future<void> _getPlace(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        if (address.isEmpty) {
          if (mounted) {
            _locationController.text = "Adres detayı bulunamadı.";
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bu konum için adres detayı bulunamadı.')),
            );
          }
        } else {
          _locationController.text = address;
        }
      } else {
        if (mounted) {
          _locationController.text = "Adres bulunamadı.";
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu konum için adres bulunamadı.')),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _locationController.text = "Adres alınırken hata oluştu.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adres alınamadı: ${e.toString()}')),
        );
      }
    }
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade700.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.event == null ? 'Yeni Etkinlik Oluştur' : 'Etkinliği Düzenle',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(controller: _titleController, labelText: 'Başlık', icon: Icons.title),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _descriptionController, labelText: 'Açıklama', icon: Icons.description),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _locationController, labelText: 'Konum Adresi', icon: Icons.location_on),
                  const SizedBox(height: 16),
                  _buildLocationPicker(context),
                  const SizedBox(height: 16),
                  if (_categories.isNotEmpty)
                    _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildDateTimePicker(
                    context,
                    label: 'Başlangıç Zamanı',
                    selectedDate: _startTime,
                    onPressed: () async {
                      final pickedDate = await _pickDateTime(context, _startTime);
                      if (pickedDate != null) {
                        setState(() {
                          _startTime = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePicker(
                    context,
                    label: 'Bitiş Zamanı',
                    selectedDate: _endTime,
                    onPressed: () async {
                      final pickedDate = await _pickDateTime(context, _endTime);
                      if (pickedDate != null) {
                        setState(() {
                          _endTime = pickedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('İptal', style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple.shade300,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final request = EventRequest(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              location: _locationController.text,
                              categoryId: _categoryId,
                              startTime: _startTime,
                              endTime: _endTime,
                              latitude: _selectedLocation?.latitude,
                              longitude: _selectedLocation?.longitude,
                            );
                            Navigator.pop(context, request);
                          }
                        },
                        child: const Text('Ekle'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, {required String label, required DateTime selectedDate, required VoidCallback onPressed}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(Icons.calendar_today, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Haritadan Konum Seç', style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final LatLng? result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
            if (result != null) {
              setState(() {
                _selectedLocation = result;
                _locationController.text = 'Adres aranıyor...';
              });
              await _getPlace(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _selectedLocation == null
                        ? 'Konum Seç'
                        : 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.map, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _categoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
      ),
      dropdownColor: Colors.deepPurple.shade200,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: _categories.map((category) {
        return DropdownMenuItem(value: category.id, child: Text(category.name, style: const TextStyle(color: Colors.white)));
      }).toList(),
      onChanged: (value) => setState(() => _categoryId = value),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
