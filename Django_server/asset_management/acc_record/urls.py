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
router.register('Transaction_All', views.TransactionAll, basename='transaction')
router.register('Investment_All', views.InvestmentAll, basename='investment')
router.register('Hashtag', views.Hashtag, basename='tag')
urlpatterns = [
    path('account_record/', include(router.urls), name='account-record'),
    path('hashtag/', views.HashTagControlAPI.as_view()),
    path('transaction_info/<year>/<month>/', views.MonthlyTransaction.as_view()),
    path('transaction_info/<year>/', views.YearlyTransaction.as_view()),
    path('transaction_info/rangedate/', views.DateRangeTransaction.as_view()),
    path('transaction_management/<accountnumber>/',views.TransactionBasics.as_view()),
]

# router.register('Category', views.Category, basename='category')
# router.register('Company_nickname', views.Company_Nickname, basename='companyname')