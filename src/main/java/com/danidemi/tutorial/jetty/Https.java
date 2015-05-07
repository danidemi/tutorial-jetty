package com.danidemi.tutorial.jetty;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.http.HttpVersion;
import org.eclipse.jetty.server.Connector;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.HttpConfiguration;
import org.eclipse.jetty.server.HttpConnectionFactory;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.SecureRequestCustomizer;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.server.SslConnectionFactory;
import org.eclipse.jetty.server.handler.AbstractHandler;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.util.ssl.SslContextFactory;
 
/**
 * A Jetty server with HTTPS.
 * You should execute <pre>src/main/scripts/generate_keystore.sh</pre> to generate, or renew, the keystore
 * that contains the self signed certificate and the private key.
 */
public class Https
{
    public static void main( String[] args ) throws Exception
    {
        String keystorePath = new File("./secrets/keystore").getAbsolutePath();
        File keystoreFile = new File(keystorePath);
        if (!keystoreFile.exists()) throw new FileNotFoundException(keystoreFile.getAbsolutePath());

        Server server = new Server();
 
        HttpConfiguration httpsConfig = new HttpConfiguration();
        httpsConfig.setSecureScheme("https");
        httpsConfig.setSecurePort(8443);
        httpsConfig.setOutputBufferSize(32768);
 
        SslContextFactory sslContextFactory = new SslContextFactory();
        sslContextFactory.setKeyStorePath(keystoreFile.getAbsolutePath());
        sslContextFactory.setKeyStorePassword("pazzword");
        sslContextFactory.setTrustStorePath(keystoreFile.getAbsolutePath());
        sslContextFactory.setTrustStorePassword("pazzword");
 
        httpsConfig.addCustomizer(new SecureRequestCustomizer());

        ServerConnector https = new ServerConnector(server,
            new SslConnectionFactory(sslContextFactory,HttpVersion.HTTP_1_1.asString()),
                new HttpConnectionFactory(httpsConfig));
        https.setPort(8443);
        https.setIdleTimeout(500000);
 
        server.setConnectors(new Connector[] {  
        		https });
        
        server.setHandler( new AbstractHandler(){
        	
        	public void handle(String target, Request baseRequest,
        			HttpServletRequest request, HttpServletResponse response)
        					throws IOException, ServletException {
        		response.getWriter().print("HTTPS " + new Date());
        		response.flushBuffer();
        	}
        	
        });
        
        server.start();
        server.join();
    }
    
}