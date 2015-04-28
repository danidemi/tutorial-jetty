package com.danidemi.tutorial.jetty;

import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.server.handler.ContextHandler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.server.handler.ResourceHandler;

public class ResourceHandlerTutorial {
	
    public static void main( String[] args ) throws Exception {
        // Create the Server object and a corresponding ServerConnector and then
        // set the port for the connector. In this example the server will
        // listen on port 8080. If you set this to port 0 then when the server
        // has been started you can called connector.getLocalPort() to
        // programmatically get the port the server started on.
        Server server = new Server();
        ServerConnector connector = new ServerConnector(server);
        connector.setPort(8080);
        server.setConnectors(new Connector[] { connector });
 
        // Create a Context Handler and ResourceHandler. The ContextHandler is
        // getting set to "/" path but this could be anything you like for
        // builing out your url. Note how we are setting the ResourceBase using
        // our jetty maven testing utilities to get the proper resource
        // directory, you needn't use these, you simply need to supply the paths
        // you are looking to serve content from.
        ContextHandler context1 = new ContextHandler();
        context1.setContextPath("/");
        ResourceHandler rh1 = new ResourceHandler();
        rh1.setDirectoriesListed(true);
        rh1.setWelcomeFiles(new String[]{ "index.html" });
        rh1.setResourceBase("./src/main/resources");
        context1.setHandler(rh1);
 
        // Create a ContextHandlerCollection and set the context handlers to it.
        // This will let jetty process urls against the declared contexts in
        // order to match up content.
        ContextHandlerCollection contexts = new ContextHandlerCollection();
        contexts.setHandlers(new Handler[] { context1 });
 
        server.setHandler(contexts);
 
        // Start things up!
        server.start();
         
        // Dump the server state
        System.out.println(server.dump());
 
        // The use of server.join() the will make the current thread join and
        // wait until the server is done executing.
        // See http://docs.oracle.com/javase/7/docs/api/java/lang/Thread.html#join()
        server.join();
    }
}
