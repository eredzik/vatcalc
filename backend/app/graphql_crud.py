import graphene
from graphene_sqlalchemy import SQLAlchemyObjectType

from . import models
from .database import db_session


class TradingPartner(graphene.ObjectType):
    uuid = graphene.NonNull(graphene.Int)
    nip_number = graphene.String()
    name = graphene.String()
    adress = graphene.String()


class Query(graphene.ObjectType):
    all_partners = graphene.NonNull(graphene.List(graphene.NonNull(TradingPartner)))

    def resolve_all_partners(self, info):

        query = models.TradingPartner.query
        return query.all()


class CreateTradingPartner(graphene.Mutation):
    class Arguments:
        nip_number = graphene.String()
        name = graphene.String()
        adress = graphene.String()

    ok = graphene.Boolean()
    trading_partner = graphene.Field(TradingPartner)

    def mutate(root, info, nip_number, name, adress):
        trading_partner = (
            db_session.query(models.TradingPartner)
            .filter(models.TradingPartner.nip_number == nip_number)
            .first()
        )
        if not trading_partner:
            trading_partner = models.TradingPartner(
                name=name, nip_number=nip_number, adress=adress
            )
            db_session.add(trading_partner)
            db_session.commit()
            db_session.flush()
            ok = True
        else:
            ok = False

        return CreateTradingPartner(ok=ok, trading_partner=trading_partner)


class Mutation(graphene.ObjectType):
    create_trading_partner = CreateTradingPartner.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
