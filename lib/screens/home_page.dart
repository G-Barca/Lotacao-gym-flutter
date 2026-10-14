import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pessoa.dart';
import '../widgets/pessoa_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Cores da Academia

  static const Color corFundo = Color(0xFF1B1B1F);
  static const Color corCard = Color(0xFF2A2A30);
  static const Color corDestaque = Color(0xFFFF6B1A);

  // Capacidade máxima

  final int maxCapacity = 50;

  // Lista de pessoas

  final List<Pessoa> pessoas = [];

  // Controllers

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    idController.dispose();
    super.dispose();
  }


  // Getters
  
  int get pessoasNoAmbiente => pessoas.where((p) => p.estaNoAmbiente).length;
  bool get isFull => pessoasNoAmbiente >= maxCapacity;
  bool get isAlmostFull => pessoasNoAmbiente >= maxCapacity * 0.8 && !isFull;

  String get statusMessage {
    if (isFull) return 'Ambiente lotado';
    if (isAlmostFull) return 'Atenção: ambiente quase cheio';
    return 'Pode entrar';
  }

  Color get statusColor {
    if (isFull) return const Color(0xFFFF5252);
    if (isAlmostFull) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }


  // Feedback (SnackBar)

  void _mostrarSnackBar(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor:
              erro ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        ),
      );
  }

  // AlertDialog

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }


  // Operações/regras

  void cadastrarPessoa() {
    final nome = nomeController.text.trim();
    final identificacao = idController.text.trim();

    // Regra 3: campos obrigatórios
    if (nome.isEmpty || identificacao.isEmpty) {
      _mostrarSnackBar('Preencha o nome e a identificação!', erro: true);
      return;
    }

    // Regra 1: capacidade
    if (isFull) {
      _mostrarSnackBar(
        'Não é possível realizar a entrada. Ambiente lotado!',
        erro: true,
      );
      return;
    }

    // Regra 4: identificação duplicada 
    final jaNoAmbiente = pessoas.any(
      (p) => p.identificacao == identificacao && p.estaNoAmbiente,
    );
    if (jaNoAmbiente) {
      _mostrarSnackBar(
        'Já existe uma pessoa no ambiente com essa identificação!',
        erro: true,
      );
      return;
    }

    setState(() {
      pessoas.insert(
        0,
        Pessoa(
          nome: nome,
          identificacao: identificacao,
          dataEntrada: DateTime.now(),
        ),
      );
    });

    nomeController.clear();
    idController.clear();
    _mostrarSnackBar('Pessoa cadastrada com sucesso!');
  }

  Future<void> registrarSaida(Pessoa pessoa) async {

    // Regra 2: n registrar saida 2 vezes
    
    if (!pessoa.estaNoAmbiente) {
      _mostrarSnackBar('Esta pessoa já registrou a saída!', erro: true);
      return;
    }

    final confirmou = await _confirmar(
      titulo: 'Registrar saída?',
      mensagem: 'Deseja realmente registrar a saída de ${pessoa.nome}?',
    );
    if (!confirmou || !mounted) return;

    setState(() {
      pessoa.registrarSaida();
    });
    _mostrarSnackBar('Saída registrada com sucesso!');
  }

  Future<void> excluirPessoa(Pessoa pessoa) async {
    final confirmou = await _confirmar(
      titulo: 'Excluir registro?',
      mensagem: 'Deseja realmente excluir o registro de ${pessoa.nome}?',
    );
    if (!confirmou || !mounted) return;

    setState(() {
      pessoas.remove(pessoa);
    });
    _mostrarSnackBar('Registro excluído com sucesso!');
  }

  // Interface
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111114),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, color: corDestaque),
            const SizedBox(width: 8),
            Text(
              'Controle de Lotação - Academia',
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCabecalho(),
            _buildFormulario(),
            Expanded(child: _buildLista()),
          ],
        ),
      ),
    );
  }

  // Contador

  Widget _buildCabecalho() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/academia.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(150),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Pessoas no ambiente',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
          ),
          Text(
            '$pessoasNoAmbiente / $maxCapacity',
            style: GoogleFonts.oswald(
              fontSize: 48,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Cadastro

  Widget _buildFormulario() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _campo(nomeController, 'Nome da pessoa', Icons.person),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _campo(idController, 'Identificação / matrícula',
                    Icons.badge),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: cadastrarPessoa,
                icon: const Icon(Icons.person_add),
                label: const Text('CADASTRAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: corDestaque,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label, IconData icone) {
    return TextField(
      controller: controller,
      style: GoogleFonts.roboto(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icone, color: corDestaque),
        filled: true,
        fillColor: corCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ListView

  Widget _buildLista() {
    if (pessoas.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma pessoa cadastrada',
          style: GoogleFonts.roboto(fontSize: 16, color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: pessoas.length,
      itemBuilder: (context, index) {
        final pessoa = pessoas[index];
        return PessoaItem(
          key: ObjectKey(pessoa),
          pessoa: pessoa,
          onSaida: () => registrarSaida(pessoa),
          onExcluir: () => excluirPessoa(pessoa),
        );
      },
    );
  }
}