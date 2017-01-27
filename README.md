# series-manager

Após checkout do projeto, executar 'pod install' para instalar as bibliotecas utilizadas.

A primeira tela que aparecerá será a tela de login. Após o login, serão carregadas todas as séries que o usuário está assistindo, bem como alguns detalhes de cada série (próximo episódio a ser assistido, data de exibição desse episódio e quantos por cento já foi assistido dessa série). Por padrão estará ligado um filtro para as séries já encerradas não aparecerem. Isso pode ser alterado tocando no botão que está no canto superior esquerdo.

Ao selecionar uma série serão apresentadas as informações do próximo episódio que o usuário deverá assistir, junto com os botões para navegar entre os episódios da mesma temporada e um botão para marcar o episódio como assistido.

Na aba perfil constarão algumas estatísticas a respeito das séries que o usuário já assistiu.

Após as requisições da listagem das séries e do perfil os dados são cacheados. Na próxima vez que o app for aberto, primeiramente os dados serão carregados do cache, enquanto uma requisição é feita em background por dados mais atualizados. Assim que essa requisição termina, a tela é atualizada.
