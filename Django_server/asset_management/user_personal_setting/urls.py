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
router.register('Company_nickname', views.Company_Nickname, basename='nickname')
router.register('Category', views.Category, basename='category')
# router.register(r'Budget_setting/(?P<year>\d+)/(?P<month>\d+)', views.MonthBudgetAPI, basename='budget')

urlpatterns = [
    path('user_setting/', include(router.urls), name='personal-settings'),
    path('budget_setting/', views.MonthBudgetAPI.as_view()),
    path('budget_setting/default/', views.MonthBudgetAPI.as_view())
]
