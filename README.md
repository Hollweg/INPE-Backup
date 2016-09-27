#INPE Cluster Backup

##A proposta

**O CRS-INPE realiza diariamente simulações do conteúdo eletrônico total da ionosfera através do SUPIM-DAVS.** </br>
Essas simulações são feitas utilizando dados de observações, rodadas em uma das máquinas do cluster do instituto de pesquisa. 

Entretanto, **não havia um sistema inteligente de backup** para salvar os dados das simulações do SUPIM-DAVS e as máquinas virtualizadas no INPE, e para isso foi desenvolvido esse projeto.

**P.S.: Todos os dados sensíveis, como paths, IPs externos e locais, nomes de pastas e arquivos, foram ocultos por caráter de segurança.**

##Utilidade

Tendo em vista que não existia nenhum sistema para manterem os arquivos sensíveis do CRS-INPE a salvo de falhas, **desenvolvi alguns scripts em Shell que fazem o backup dos dados diariamente (SUPIM-DAVS), e semanalmente (VMs).** 

Os scripts foram todos desenvolvidos para um **sistema LINUX** e configurados para rodarem no **CRON** de uma máquina disponibilizada para o backup.

##Como funciona?

Para backup dos dados de simulação ionosférica, foi desenvolvido o script _julianday.sh_ **a fim de calcular o dia juliano atual e dois dias julianos anteriores para facilitar o processo de backup dos dados**, tendo em vista que o sistema de simulação ionosférica se baseia em dias julianos.

O arquivo _backup.sh_ é responsável por executar o script _julianday.sh_ e assim **verificar se o ano é ou não bissexto, e fazer a verificação para gerenciamento das pastas de backup**, para dessa forma, não sobreescrever as pastas ou salvar os arquivos de interesse em um lugar errado. </br>
Assim, **acessa-se por ssh a máquina de backup, verifica-se a existência dos últimos dados a serem copiados e então é efetuado o backup dos arquivos sensíveis de simulações se os mesmos estiverem disponíveis para serem copiados.** 

O arquivo _cronbackupmachines.sh_ é responsável por **semanalmente desligar as VMs virtualizadas no INPE, criar imagens específicas de cada uma das máquinas, e então religá-las após este processo.** </br>
Esse é um trabalho bastante complexo, pois são desligadas máquinas sensíveis do sistema. </br>
Portanto, é um procedimento que **não deve admitir falhas**.</br>
Tendo em vista que os arquivos de imagens das máquinas são grandes, é necessário fazer um gerenciamento de memória no servidor, para que sempre haja espaço para o backup. 

O arquivo _backupVMs.sh_ é responsável por **acessar o servidor, e então copiar os arquivos .img para a máquina de backup, bem como fazer todo o gerenciamento de memória local, e a verificação se o backup no servidor foi realizado com sucesso.** </br>
Para isso são verificados alguns pontos, como **tamanho e existência de arquivos na pasta**, etc..

Além disso, foi configurado um sistema _postfix_ na máquina de backup. </br>
Assim, a cada realização de novo procedimento de backup, **é enviado por email um relatório do respectivo backup às pessoas de interesse.**

Abaixo, fica uma imagem do email de backup recebido do dia juliano 268.

![Imgur](http://i.imgur.com/mmyOUOk.png)


##Direitos

**Dificilmente o projeto em si possa ser reproduzido, pois se trata de um sistema de backup bastante complexo para um caso específico.** </br>

Entretanto, algumas ideias de busca e gerenciamento de memória em situações de backup **podem ser reutilizadas.** </br>
Caso isso seja feito, e algum trecho do código seja copiado, apenas peço para **manterem/referenciarem créditos ao autor**.



Enjoy!

**Hollweg**



