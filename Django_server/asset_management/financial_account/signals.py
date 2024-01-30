from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from acc_record.models import *
from django.db.models import Sum

@receiver([post_save, post_delete], sender=Transaction)
def update_balance(sender, instance, **kwargs):
    account = instance.transaction_from  # Assuming 'transaction_from' is the ForeignKey field pointing to Financialaccount
    
    withdrawals = Transaction.objects.filter(transaction_from=account).aggregate(Sum('withdrawal_amount'))['withdrawal_amount__sum'] or 0
    deposits = Transaction.objects.filter(transaction_from=account).aggregate(Sum('deposit_amount'))['deposit_amount__sum'] or 0
    
    account.account_balance = deposits - withdrawals
    account.save()
# def update_assetamount(sender, instance, **kwargs):
#     account = instance.transaction_from
#     sum_value = parent.children.aggregate(Sum('number'))['number__sum'] or 0
#     parent.sum = sum_value
#     parent.save()