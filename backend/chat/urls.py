from django.urls import path
from .views import (
    ConversationListView,
    CreateOrGetConversationView,
    MessageListView,
    SendMessageView,
)

urlpatterns = [
    path('conversations/', ConversationListView.as_view(), name='conversation_list'),
    path('conversations/start/', CreateOrGetConversationView.as_view(), name='start_conversation'),
    path('conversations/<int:conversation_id>/messages/', MessageListView.as_view(), name='message_list'),
    path('conversations/<int:conversation_id>/send/', SendMessageView.as_view(), name='send_message'),
]