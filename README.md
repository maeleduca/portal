# Portal Hotspot UniFi com FreeRADIUS e MySQL

Sistema completo de portal hotspot para redes UniFi com autenticação WPA2 Enterprise, usando FreeRADIUS e MySQL. Suporta múltiplos sites UniFi e gerenciamento centralizado.

## 📋 Funcionalidades

- ✅ Autenticação WPA2 Enterprise
- 🌐 Portal web para autogerenciamento de usuários
- 👥 Área administrativa com múltiplos níveis de acesso
- 🔄 Integração automática com UniFi Controller
- 📱 Interface responsiva e amigável
- 🔒 Sistema seguro de autenticação
- 📊 Relatórios e estatísticas de uso
- 🔄 Suporte a múltiplos sites UniFi

## 🚀 Começando

### Pré-requisitos

1. Servidor VPS:
   - Ubuntu 20.04 LTS
   - Mínimo 2GB RAM
   - 20GB de espaço em disco
   - Acesso root

2. UniFi Controller:
   - Instalado em outro servidor
   - Acesso administrativo
   - URL de acesso ao controller

3. Domínio:
   - Apontando para o IP do servidor
   - Acesso ao gerenciamento DNS

### 📥 Instalação

1. Acesse seu servidor:
   ```bash
   ssh root@seu_ip_do_servidor
   ```

2. Instale o Git:
   ```bash
   apt update && apt install git -y
   ```

3. Clone o repositório:
   ```bash
   git clone https://github.com/seuusuario/unifi-hotspot-portal.git
   cd unifi-hotspot-portal
   ```

4. Configure os arquivos principais:

   a. Banco de Dados (`config/database.conf`):
   ```bash
   nano config/database.conf
   ```
   ```ini
   DB_USER=seu_usuario
   DB_PASS=sua_senha_forte
   DB_NAME=radius
   BACKUP_DIR=/var/backups/radius
   ```

   b. UniFi Controller (`config/unifi.conf`):
   ```bash
   nano config/unifi.conf
   ```
   ```ini
   UNIFI_CONTROLLER_URL=https://seu_controller:8443
   UNIFI_USER=admin
   UNIFI_PASS=senha_admin
   UNIFI_SITE=default
   ```

   c. RADIUS (`config/radius.conf`):
   ```bash
   nano config/radius.conf
   ```
   ```ini
   RADIUS_CLIENT_SECRET=senha_forte_radius
   RADIUS_CLIENT_NETWORK=192.168.1.0/24
   RADIUS_LISTEN_IP=0.0.0.0
   ```

5. Execute a instalação:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## 🛠️ Configuração Pós-Instalação

### 1. Configuração do UniFi Controller

1. Acesse seu UniFi Controller
2. Vá em Settings > Wireless Networks
3. Crie uma nova rede:
   - Nome: Sua escolha
   - Segurança: WPA2 Enterprise
   - RADIUS Server: IP do seu servidor
   - RADIUS Port: 1812
   - RADIUS Secret: Valor de RADIUS_CLIENT_SECRET

### 2. Primeiro Acesso ao Portal

1. Acesso Administrativo:
   - URL: https://seu_dominio/admin
   - Usuário: admin
   - Senha: admin123
   - ⚠️ Troque a senha no primeiro acesso!

2. Portal do Usuário:
   - URL: https://seu_dominio
   - Os usuários podem se cadastrar

## 📚 Guia de Uso

### Para Administradores

1. Gerenciamento de Sites:
   - Menu: Sites > Gerenciar
   - Adicione/remova sites
   - Configure políticas por site

2. Usuários:
   - Visualize todos os usuários
   - Gerencie permissões
   - Monitore uso

3. Relatórios:
   - Acesso: Menu > Relatórios
   - Exportação em CSV/PDF
   - Filtros personalizados

### Para Usuários

1. Cadastro:
   - Acesse o portal
   - Clique em "Registrar"
   - Preencha os dados

2. Gerenciamento:
   - Login no portal
   - Altere seus dados
   - Visualize histórico

## 🔧 Manutenção

### Backups

Os backups são automáticos:
- Horário: 2h da manhã
- Local: /var/backups/radius/
- Retenção: 30 dias

Para backup manual:
```bash
./scripts/backup.sh
```

### Logs

Monitore os logs:
```bash
# RADIUS
tail -f /var/log/freeradius/radius.log

# Portal Web
tail -f /var/log/nginx/error.log
```

### Atualizações

1. Atualize o sistema:
   ```bash
   apt update && apt upgrade -y
   ```

2. Atualize o portal:
   ```bash
   cd /caminho/do/portal
   git pull
   ./scripts/update.sh
   ```

## 🔒 Segurança

Recomendações importantes:

1. Senhas:
   - Altere todas as senhas padrão
   - Use senhas fortes (mín. 12 caracteres)
   - Troque periodicamente

2. Firewall:
   - Mantenha apenas portas necessárias
   - Configure regras específicas
   - Monitore tentativas de acesso

3. SSL/TLS:
   - Use HTTPS
   - Mantenha certificados atualizados
   - Configure HSTS

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs
2. Consulte a documentação
3. Abra uma issue no GitHub
4. Verifique a [Wiki](link_para_wiki)

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request