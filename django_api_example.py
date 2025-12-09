"""
Django API Views - Exemplo de Implementação
============================================

Este arquivo contém exemplos de views Django para integrar com o frontend Vue.js.
Copie e adapte conforme sua estrutura de projeto Django.

Instalação de Dependências:
---------------------------
pip install djangorestframework
pip install djangorestframework-simplejwt
pip install django-cors-headers

Configuração no settings.py:
----------------------------
INSTALLED_APPS = [
    ...
    'rest_framework',
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:5173",
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}
"""

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken
from django.db.models import Count, Q
from datetime import datetime, timedelta


# ============================================
# AUTENTICAÇÃO
# ============================================

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    POST /api/auth/login/
    
    Request:
    {
        "email": "user@example.com",
        "password": "senha123"
    }
    
    Response:
    {
        "user": {
            "id": "1",
            "email": "user@example.com",
            "name": "Nome do Usuário"
        },
        "tokens": {
            "access": "jwt_token...",
            "refresh": "jwt_token..."
        }
    }
    """
    email = request.data.get('email')
    password = request.data.get('password')
    
    if not email or not password:
        return Response(
            {'error': 'Email e senha são obrigatórios'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Tenta autenticar com email ou username
    user = authenticate(username=email, password=password)
    
    if not user:
        # Tenta buscar por email se não encontrou por username
        from django.contrib.auth import get_user_model
        User = get_user_model()
        try:
            user_obj = User.objects.get(email=email)
            user = authenticate(username=user_obj.username, password=password)
        except User.DoesNotExist:
            pass
    
    if user:
        refresh = RefreshToken.for_user(user)
        return Response({
            'user': {
                'id': str(user.id),
                'email': user.email,
                'name': user.get_full_name() or user.username
            },
            'tokens': {
                'access': str(refresh.access_token),
                'refresh': str(refresh)
            }
        })
    
    return Response(
        {'error': 'Credenciais inválidas'},
        status=status.HTTP_401_UNAUTHORIZED
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_view(request):
    """POST /api/auth/logout/"""
    return Response({'message': 'Logout realizado com sucesso'})


@api_view(['POST'])
@permission_classes([AllowAny])
def refresh_token_view(request):
    """
    POST /api/auth/refresh/
    
    Request:
    {
        "refresh": "jwt_refresh_token..."
    }
    
    Response:
    {
        "access": "new_jwt_access_token..."
    }
    """
    from rest_framework_simplejwt.tokens import RefreshToken
    
    refresh_token = request.data.get('refresh')
    
    if not refresh_token:
        return Response(
            {'error': 'Refresh token é obrigatório'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        refresh = RefreshToken(refresh_token)
        return Response({
            'access': str(refresh.access_token)
        })
    except Exception as e:
        return Response(
            {'error': 'Token inválido'},
            status=status.HTTP_401_UNAUTHORIZED
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user_view(request):
    """GET /api/auth/me/"""
    user = request.user
    return Response({
        'id': str(user.id),
        'email': user.email,
        'name': user.get_full_name() or user.username
    })


# ============================================
# EDITAIS
# ============================================

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def edital_list_create(request):
    """
    GET /api/editals/
    POST /api/editals/
    """
    # Importe seu modelo Edital
    from apps_edital.models import Edital  # Ajuste o import conforme seu projeto
    
    if request.method == 'GET':
        editals = Edital.objects.all().order_by('-created_at')
        
        data = []
        for e in editals:
            data.append({
                'id': str(e.id),
                'title': e.title if hasattr(e, 'title') else '',
                'description': e.description if hasattr(e, 'description') else '',
                'status': e.status if hasattr(e, 'status') else 'open',
                'metadata': e.metadata if hasattr(e, 'metadata') else {},
                'created_at': e.created_at.isoformat() if hasattr(e, 'created_at') else None,
                'updated_at': e.updated_at.isoformat() if hasattr(e, 'updated_at') else None,
                'files': {
                    'main_pdf': e.main_pdf.url if hasattr(e, 'main_pdf') and e.main_pdf else None,
                    'annexes': [],
                    'results': []
                }
            })
        
        return Response(data)
    
    elif request.method == 'POST':
        # Criar novo edital
        data = request.data
        
        edital = Edital.objects.create(
            title=data.get('title'),
            description=data.get('description'),
            status=data.get('status', 'open'),
            metadata=data.get('metadata', {})
        )
        
        return Response({
            'id': str(edital.id),
            'title': edital.title,
            'description': edital.description,
            'status': edital.status,
            'metadata': edital.metadata,
            'created_at': edital.created_at.isoformat(),
            'updated_at': edital.updated_at.isoformat(),
            'files': {
                'main_pdf': None,
                'annexes': [],
                'results': []
            }
        }, status=status.HTTP_201_CREATED)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
def edital_detail(request, pk):
    """
    GET /api/editals/{id}/
    PUT /api/editals/{id}/
    DELETE /api/editals/{id}/
    """
    from apps_edital.models import Edital
    
    try:
        edital = Edital.objects.get(pk=pk)
    except Edital.DoesNotExist:
        return Response(
            {'error': 'Edital não encontrado'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        return Response({
            'id': str(edital.id),
            'title': edital.title,
            'description': edital.description,
            'status': edital.status,
            'metadata': edital.metadata,
            'created_at': edital.created_at.isoformat(),
            'updated_at': edital.updated_at.isoformat(),
            'files': {
                'main_pdf': edital.main_pdf.url if edital.main_pdf else None,
                'annexes': [],
                'results': []
            }
        })
    
    elif request.method == 'PUT':
        data = request.data
        edital.title = data.get('title', edital.title)
        edital.description = data.get('description', edital.description)
        edital.status = data.get('status', edital.status)
        edital.metadata = data.get('metadata', edital.metadata)
        edital.save()
        
        return Response({
            'id': str(edital.id),
            'title': edital.title,
            'description': edital.description,
            'status': edital.status,
            'metadata': edital.metadata,
            'updated_at': edital.updated_at.isoformat()
        })
    
    elif request.method == 'DELETE':
        edital.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ============================================
# MÉTRICAS
# ============================================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def engagement_metrics(request):
    """
    GET /api/metrics/engagement/
    
    Response:
    {
        "total_messages": 760,
        "total_users": 111,
        "total_editals": 5,
        "editals": [...]
    }
    """
    from apps_discussao.models import Mensagem  # Ajuste conforme seu modelo
    from apps_edital.models import Edital
    
    # Total de mensagens
    total_messages = Mensagem.objects.count()
    
    # Total de usuários únicos
    total_users = Mensagem.objects.values('user_id').distinct().count()
    
    # Total de editais
    total_editals = Edital.objects.count()
    
    # Métricas por edital
    editals_metrics = []
    editals = Edital.objects.all()
    
    for edital in editals:
        messages = Mensagem.objects.filter(edital=edital)
        message_count = messages.count()
        unique_users = messages.values('user_id').distinct().count()
        last_message = messages.order_by('-timestamp').first()
        
        editals_metrics.append({
            'id': str(edital.id),
            'title': edital.title,
            'messageCount': message_count,
            'uniqueUsers': unique_users,
            'lastMessage': last_message.timestamp.date().isoformat() if last_message else None
        })
    
    return Response({
        'total_messages': total_messages,
        'total_users': total_users,
        'total_editals': total_editals,
        'editals': editals_metrics
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def messages_list(request):
    """
    GET /api/metrics/messages/?edital_id=1
    
    Response:
    [
        {
            "id": "1",
            "userId": "user_1",
            "userEmail": "maria@example.com",
            "question": "Pergunta...",
            "botResponse": "Resposta...",
            "timestamp": "2024-01-15T14:30:00Z",
            "editalId": "1"
        }
    ]
    """
    from apps_discussao.models import Mensagem
    
    edital_id = request.GET.get('edital_id')
    
    messages = Mensagem.objects.all().order_by('-timestamp')
    
    if edital_id:
        messages = messages.filter(edital_id=edital_id)
    
    data = []
    for msg in messages[:100]:  # Limitar a 100 mensagens
        data.append({
            'id': str(msg.id),
            'userId': str(msg.user_id) if hasattr(msg, 'user_id') else '',
            'userEmail': msg.user_email if hasattr(msg, 'user_email') else '',
            'question': msg.question if hasattr(msg, 'question') else msg.content,
            'botResponse': msg.bot_response if hasattr(msg, 'bot_response') else '',
            'timestamp': msg.timestamp.isoformat() if hasattr(msg, 'timestamp') else None,
            'editalId': str(msg.edital_id) if hasattr(msg, 'edital_id') else ''
        })
    
    return Response(data)


# ============================================
# HISTÓRICO DE CONVERSAS
# ============================================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def sessions_list(request):
    """
    GET /api/history/sessions/?limit=50&offset=0
    """
    from apps_discussao.models import Conversa  # Ajuste conforme seu modelo
    
    limit = int(request.GET.get('limit', 50))
    offset = int(request.GET.get('offset', 0))
    
    sessions = Conversa.objects.all().order_by('-iniciado_em')[offset:offset+limit]
    
    data = []
    for session in sessions:
        data.append({
            'id': str(session.id),
            'userId': str(session.user_id) if hasattr(session, 'user_id') else '',
            'userEmail': session.user_email if hasattr(session, 'user_email') else '',
            'startTime': session.iniciado_em.isoformat() if hasattr(session, 'iniciado_em') else None,
            'endTime': session.encerrado_em.isoformat() if hasattr(session, 'encerrado_em') else None,
            'messageCount': session.mensagens.count() if hasattr(session, 'mensagens') else 0,
            'edital': session.edital.title if hasattr(session, 'edital') and session.edital else ''
        })
    
    return Response(data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def session_detail(request, pk):
    """
    GET /api/history/sessions/{id}/
    """
    from apps_discussao.models import Conversa
    
    try:
        session = Conversa.objects.get(pk=pk)
    except Conversa.DoesNotExist:
        return Response(
            {'error': 'Sessão não encontrada'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    messages = []
    if hasattr(session, 'mensagens'):
        for msg in session.mensagens.all().order_by('timestamp'):
            messages.append({
                'id': str(msg.id),
                'role': 'user' if msg.is_user else 'bot',
                'content': msg.content,
                'timestamp': msg.timestamp.isoformat()
            })
    
    return Response({
        'id': str(session.id),
        'userId': str(session.user_id) if hasattr(session, 'user_id') else '',
        'userEmail': session.user_email if hasattr(session, 'user_email') else '',
        'startTime': session.iniciado_em.isoformat() if hasattr(session, 'iniciado_em') else None,
        'endTime': session.encerrado_em.isoformat() if hasattr(session, 'encerrado_em') else None,
        'messageCount': len(messages),
        'edital': session.edital.title if hasattr(session, 'edital') and session.edital else '',
        'messages': messages
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def sessions_search(request):
    """
    GET /api/history/sessions/search/?email=maria@example.com&user_id=123
    """
    from apps_discussao.models import Conversa
    
    email = request.GET.get('email')
    user_id = request.GET.get('user_id')
    
    sessions = Conversa.objects.all()
    
    if email:
        sessions = sessions.filter(user_email__icontains=email)
    
    if user_id:
        sessions = sessions.filter(user_id=user_id)
    
    sessions = sessions.order_by('-iniciado_em')[:50]
    
    data = []
    for session in sessions:
        data.append({
            'id': str(session.id),
            'userId': str(session.user_id) if hasattr(session, 'user_id') else '',
            'userEmail': session.user_email if hasattr(session, 'user_email') else '',
            'startTime': session.iniciado_em.isoformat() if hasattr(session, 'iniciado_em') else None,
            'endTime': session.encerrado_em.isoformat() if hasattr(session, 'encerrado_em') else None,
            'messageCount': session.mensagens.count() if hasattr(session, 'mensagens') else 0,
            'edital': session.edital.title if hasattr(session, 'edital') and session.edital else ''
        })
    
    return Response(data)


# ============================================
# URLs Configuration
# ============================================
"""
Adicione no seu urls.py:

from django.urls import path
from . import views

urlpatterns = [
    # Autenticação
    path('api/auth/login/', views.login_view, name='login'),
    path('api/auth/logout/', views.logout_view, name='logout'),
    path('api/auth/refresh/', views.refresh_token_view, name='refresh'),
    path('api/auth/me/', views.current_user_view, name='current_user'),
    
    # Editais
    path('api/editals/', views.edital_list_create, name='edital-list'),
    path('api/editals/<int:pk>/', views.edital_detail, name='edital-detail'),
    
    # Métricas
    path('api/metrics/engagement/', views.engagement_metrics, name='engagement'),
    path('api/metrics/messages/', views.messages_list, name='messages'),
    
    # Histórico
    path('api/history/sessions/', views.sessions_list, name='sessions'),
    path('api/history/sessions/<int:pk>/', views.session_detail, name='session-detail'),
    path('api/history/sessions/search/', views.sessions_search, name='sessions-search'),
]
"""
