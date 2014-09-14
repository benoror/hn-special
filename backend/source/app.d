import std.stdio, std.algorithm;
import vibe.d, vibe.db.mongo.mongo;

MongoCollection tags;

class Tag
{
    string username;
    string tag;
}

interface TagApi
{
public:
    Tag getTag( string username );
    void postAdd( Tag tag );
    void postUpdate( Tag tag );
}

class TagApiImpl : TagApi
{
public:
    override Tag getTag( string username )
    {
        writeln( "Getting tag: ", username );
        return tags.findOne!Tag( [ "username": username ] );
    }

    override void postAdd( Tag tag )
    {
        writeln( "Adding tag: ", tag.username );
        tags.insert( tag.serializeToBson() );
    }

    override void postUpdate( Tag tag )
    {
        writeln( "Updating tag: ", tag.username );
        tags.update( [ "username": tag.username ], tag.serializeToBson() );
    }
}

shared static this()
{
    tags = connectMongoDB( "localhost", 27017 ).getCollection( "hn.tags" );

    Tag t = new Tag();
    t.username = "Butts";
    t.tag = "Chief Butttttter";
    tags.insert( t.serializeToBson() );

    writeln( "Items: ", tags.find!Tag.map!( it => it.username ) );

    auto router = new URLRouter;
	router.registerRestInterface( new TagApiImpl );

	auto settings = new HTTPServerSettings;
    settings.bindAddresses = [ "127.0.0.1" ];
	settings.port = 8080;
	listenHTTP( settings, router );
}
