import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/pessoa.dart';

// Widgets

class PessoaItem extends StatelessWidget {
  final Pessoa pessoa;
  final VoidCallback onSaida;
  final VoidCallback onExcluir;

  const PessoaItem({
    super.key,
    required this.pessoa,
    required this.onSaida,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat("dd/MM/yyyy 'às' HH:mm");
    final noAmbiente = pessoa.estaNoAmbiente;
    final corSituacao =
        noAmbiente ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Slidable(
    
    // actions com slidable

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onSaida(),
              backgroundColor: const Color(0xFFFF6B1A),
              foregroundColor: Colors.white,
              icon: Icons.logout,
              label: 'SAÍDA',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onExcluir(),
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'EXCLUIR',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                noAmbiente ? Icons.fitness_center : Icons.directions_walk,
                color: corSituacao,
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pessoa.nome,
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${pessoa.identificacao}',
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      'Entrada: ${formato.format(pessoa.dataEntrada)}',
                      style: GoogleFonts.roboto(
                          fontSize: 14, color: Colors.white70),
                    ),
                    if (pessoa.dataSaida != null)
                      Text(
                        'Saída: ${formato.format(pessoa.dataSaida!)}',
                        style: GoogleFonts.roboto(
                            fontSize: 14, color: Colors.white70),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Situação: ${pessoa.situacao}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: corSituacao,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}