"""asset_management URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from rest_framework.routers import DefaultRouter
from django.urls import path, include
from . import views

router = DefaultRouter()
router.register('bank_account', views.AccountBase, basename='bank')
router.register('card_account', views.CardBase, basename='card')
router.register('pay_account', views.PayBase, basename='pay')
urlpatterns = [
    path('account_management/', include(router.urls), name='account-mangement'),
    # path('account_list/', views.AccountBase.as_view({'get': 'list'})),
    # path('account_ret/', views.AccountBase.as_view({'get': 'retrieve'})),
    path('money_account_list/', views.Account_Book_Bookmark.as_view()),
]
