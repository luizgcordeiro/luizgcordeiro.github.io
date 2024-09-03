import pygame
import sys
import networkx as nx

# Inicializa o Pygame
pygame.init()

# Define as cores
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
YELLOW = (255, 255, 0)
GRAY = (200, 200, 200)
BLUE = (0, 0, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)
DARK_GRAY = (169, 169, 169)  # Cor para luz apagada

# Define o tamanho da janela
WINDOW_SIZE = (800, 600)
RADIUS = 20  # Raio dos nós

# Cria a janela
screen = pygame.display.set_mode(WINDOW_SIZE)
pygame.display.set_caption("Lights Out")

# Define as posições dos botões
BUTTON_SIZE = (100, 50)
ADD_LIGHT_BUTTON_POS = (10, 10)
ADD_LIGHT_ON_BUTTON_POS = (120, 10)
REMOVE_LIGHT_BUTTON_POS = (230, 10)
ADD_CONNECTION_BUTTON_POS = (340, 10)
REMOVE_CONNECTION_BUTTON_POS = (450, 10)
PLAY_BUTTON_POS = (560, 10)

# Cria um grafo vazio
graph = nx.Graph()
pos = {}
light_states = {}  # Dicionário para armazenar o estado das luzes (True = acesa, False = apagada)

# Função para desenhar o grafo
def draw_graph(graph, pos, light_states):
    for node in graph.nodes:
        color = YELLOW if light_states.get(node, False) else DARK_GRAY
        pygame.draw.circle(screen, color, pos[node], RADIUS)
        pygame.draw.circle(screen, BLACK, pos[node], RADIUS, 1)
    
    for edge in graph.edges:
        pygame.draw.line(screen, BLACK, pos[edge[0]], pos[edge[1]], 1)

# Função para desenhar os botões
def draw_buttons(mode):
    pygame.draw.rect(screen, GRAY if mode=='play' else BLUE, (*ADD_LIGHT_BUTTON_POS, *BUTTON_SIZE))
    pygame.draw.rect(screen, GRAY if mode=='play' else BLUE, (*ADD_LIGHT_ON_BUTTON_POS, *BUTTON_SIZE))
    pygame.draw.rect(screen, GRAY if mode=='play' else BLUE, (*REMOVE_LIGHT_BUTTON_POS, *BUTTON_SIZE))
    pygame.draw.rect(screen, GRAY if mode=='play' else GREEN, (*ADD_CONNECTION_BUTTON_POS, *BUTTON_SIZE))
    pygame.draw.rect(screen, GRAY if mode=='play' else GREEN, (*REMOVE_CONNECTION_BUTTON_POS, *BUTTON_SIZE))
    pygame.draw.rect(screen, GRAY if mode=='play' else GRAY, (*PLAY_BUTTON_POS, *BUTTON_SIZE))
    
    # Desenhar ícone de adicionar luz apagada
    pygame.draw.circle(screen, DARK_GRAY, (ADD_LIGHT_BUTTON_POS[0] + 50, ADD_LIGHT_BUTTON_POS[1] + 25), 10)
    pygame.draw.rect(screen, BLACK, (*ADD_LIGHT_BUTTON_POS, *BUTTON_SIZE), 2)
    
    # Desenhar ícone de adicionar luz acesa
    pygame.draw.circle(screen, YELLOW, (ADD_LIGHT_ON_BUTTON_POS[0] + 50, ADD_LIGHT_ON_BUTTON_POS[1] + 25), 10)
    pygame.draw.rect(screen, BLACK, (*ADD_LIGHT_ON_BUTTON_POS, *BUTTON_SIZE), 2)
    
    # Desenhar ícone de remover luz
    pygame.draw.circle(screen, DARK_GRAY, (REMOVE_LIGHT_BUTTON_POS[0] + 50, REMOVE_LIGHT_BUTTON_POS[1] + 25), 10)
    pygame.draw.line(screen, RED, (REMOVE_LIGHT_BUTTON_POS[0] + 40, REMOVE_LIGHT_BUTTON_POS[1] + 15), (REMOVE_LIGHT_BUTTON_POS[0] + 60, REMOVE_LIGHT_BUTTON_POS[1] + 35), 3)
    pygame.draw.line(screen, RED, (REMOVE_LIGHT_BUTTON_POS[0] + 40, REMOVE_LIGHT_BUTTON_POS[1] + 35), (REMOVE_LIGHT_BUTTON_POS[0] + 60, REMOVE_LIGHT_BUTTON_POS[1] + 15), 3)
    pygame.draw.rect(screen, BLACK, (*REMOVE_LIGHT_BUTTON_POS, *BUTTON_SIZE), 2)
    
    # Desenhar ícone de adicionar conexão
    pygame.draw.circle(screen, YELLOW, (ADD_CONNECTION_BUTTON_POS[0] + 35, ADD_CONNECTION_BUTTON_POS[1] + 25), 7)
    pygame.draw.circle(screen, DARK_GRAY, (ADD_CONNECTION_BUTTON_POS[0] + 65, ADD_CONNECTION_BUTTON_POS[1] + 25), 7)
    pygame.draw.line(screen, BLACK, (ADD_CONNECTION_BUTTON_POS[0] + 35, ADD_CONNECTION_BUTTON_POS[1] + 25), (ADD_CONNECTION_BUTTON_POS[0] + 65, ADD_CONNECTION_BUTTON_POS[1] + 25), 2)
    pygame.draw.rect(screen, BLACK, (*ADD_CONNECTION_BUTTON_POS, *BUTTON_SIZE), 2)
    
    # Desenhar ícone de remover conexão
    pygame.draw.circle(screen, YELLOW, (REMOVE_CONNECTION_BUTTON_POS[0] + 35, REMOVE_CONNECTION_BUTTON_POS[1] + 25), 7)
    pygame.draw.circle(screen, DARK_GRAY, (REMOVE_CONNECTION_BUTTON_POS[0] + 65, REMOVE_CONNECTION_BUTTON_POS[1] + 25), 7)
    pygame.draw.line(screen, BLACK, (REMOVE_CONNECTION_BUTTON_POS[0] + 35, REMOVE_CONNECTION_BUTTON_POS[1] + 25), (REMOVE_CONNECTION_BUTTON_POS[0] + 65, REMOVE_CONNECTION_BUTTON_POS[1] + 25), 2)
    pygame.draw.line(screen, RED, (REMOVE_CONNECTION_BUTTON_POS[0] + 25, REMOVE_CONNECTION_BUTTON_POS[1] + 15), (REMOVE_CONNECTION_BUTTON_POS[0] + 75, REMOVE_CONNECTION_BUTTON_POS[1] + 35), 3)
    pygame.draw.line(screen, RED, (REMOVE_CONNECTION_BUTTON_POS[0] + 25, REMOVE_CONNECTION_BUTTON_POS[1] + 35), (REMOVE_CONNECTION_BUTTON_POS[0] + 75, REMOVE_CONNECTION_BUTTON_POS[1] + 15), 3)
    pygame.draw.rect(screen, BLACK, (*REMOVE_CONNECTION_BUTTON_POS, *BUTTON_SIZE), 2)

    # Texto do botão "JOGAR"
    font = pygame.font.Font(None, 24)
    text = font.render("EDITAR" if mode=='play' else "JOGAR", True, BLACK)
    screen.blit(text, (PLAY_BUTTON_POS[0] + BUTTON_SIZE[0]/2 - text.get_width()/2, PLAY_BUTTON_POS[1] + BUTTON_SIZE[1]/2 - text.get_height()/2))
    pygame.draw.rect(screen, BLACK, (*PLAY_BUTTON_POS, *BUTTON_SIZE), 2)

# Estado do modo atual
mode = 'edit'
selected_nodes = []

# Loop principal do jogo
running = True
dragging = False

number_of_nodes = 0

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            x, y = event.pos

            # Verifica se o clique foi em algum botão
            if ADD_LIGHT_BUTTON_POS[0] <= x <= ADD_LIGHT_BUTTON_POS[0] + BUTTON_SIZE[0] and ADD_LIGHT_BUTTON_POS[1] <= y <= ADD_LIGHT_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'add_light_off'
            elif ADD_LIGHT_ON_BUTTON_POS[0] <= x <= ADD_LIGHT_ON_BUTTON_POS[0] + BUTTON_SIZE[0] and ADD_LIGHT_ON_BUTTON_POS[1] <= y <= ADD_LIGHT_ON_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'add_light_on'
            elif REMOVE_LIGHT_BUTTON_POS[0] <= x <= REMOVE_LIGHT_BUTTON_POS[0] + BUTTON_SIZE[0] and REMOVE_LIGHT_BUTTON_POS[1] <= y <= REMOVE_LIGHT_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'remove_light'
            elif ADD_CONNECTION_BUTTON_POS[0] <= x <= ADD_CONNECTION_BUTTON_POS[0] + BUTTON_SIZE[0] and ADD_CONNECTION_BUTTON_POS[1] <= y <= ADD_CONNECTION_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'add_connection'
            elif REMOVE_CONNECTION_BUTTON_POS[0] <= x <= REMOVE_CONNECTION_BUTTON_POS[0] + BUTTON_SIZE[0] and REMOVE_CONNECTION_BUTTON_POS[1] <= y <= REMOVE_CONNECTION_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'remove_connection'
            elif PLAY_BUTTON_POS[0] <= x <= PLAY_BUTTON_POS[0] + BUTTON_SIZE[0] and PLAY_BUTTON_POS[1] <= y <= PLAY_BUTTON_POS[1] + BUTTON_SIZE[1]:
                selected_nodes=[]
                mode = 'edit' if mode=='play' else 'play'
            # Verifica se está jogando
            elif mode == 'play': 
                selected_nodes=[]
                for node, position in pos.items():
                    if (x - position[0]) ** 2 + (y - position[1]) ** 2 <= RADIUS ** 2:
                        # Change the state of adjacent lights
                        light_states[node] = not light_states[node]
                        for neighbor in graph.neighbors(node):
                            light_states[neighbor] = not light_states[neighbor]
                        break
            elif mode == 'edit': # Verifica se está editando
                for node, position in pos.items():
                    if (x - position[0]) ** 2 + (y - position[1]) ** 2 <= RADIUS ** 2:
                        dragging = True
                        dragged_node = node
                        break
            elif mode == 'add_light_off':
                    node = number_of_nodes
                    number_of_nodes += 1
                    graph.add_node(node)
                    pos[node] = (x, y)
                    light_states[node] = False  # Luz começa apagada
            elif mode == 'add_light_on':
                node = number_of_nodes
                number_of_nodes += 1
                graph.add_node(node)
                pos[node] = (x, y)
                light_states[node] = True  # Luz começa acesa
            elif mode == 'remove_light':
                for node, position in pos.items():
                    if (x - position[0]) ** 2 + (y - position[1]) ** 2 <= RADIUS ** 2:
                        graph.remove_node(node)
                        pos.pop(node)
                        light_states.pop(node)  # Remove o estado da luz
                        break
            elif mode == 'add_connection':
                for node, position in pos.items():
                    if (x - position[0]) ** 2 + (y - position[1]) ** 2 <= RADIUS ** 2:
                        if node not in selected_nodes: selected_nodes.append(node)
                        if len(selected_nodes) == 2:
                            graph.add_edge(selected_nodes[0], selected_nodes[1])
                            selected_nodes = []
                        break
            elif mode == 'remove_connection':
                for node, position in pos.items():
                    if (x - position[0]) ** 2 + (y - position[1]) ** 2 <= RADIUS ** 2:
                        selected_nodes.append(node)
                        if len(selected_nodes) == 2:
                            if graph.has_edge(selected_nodes[0], selected_nodes[1]):
                                graph.remove_edge(selected_nodes[0], selected_nodes[1])
                            selected_nodes = []
                        break
        elif event.type == pygame.MOUSEBUTTONUP:
            dragging = False
            dragged_node = None
        elif event.type == pygame.MOUSEMOTION:
            if dragging and dragged_node is not None:
                pos[dragged_node] = event.pos

    screen.fill(WHITE)
    draw_buttons(mode)
    draw_graph(graph, pos, light_states)
    pygame.display.flip()

pygame.quit()
sys.exit()
