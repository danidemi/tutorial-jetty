package com.danidemi.snippet;

import java.io.File;

import javax.servlet.jsp.jstl.core.Config;

import org.eclipse.jetty.server.HttpConfiguration;
import org.eclipse.jetty.server.HttpConnectionFactory;
import org.eclipse.jetty.server.SecureRequestCustomizer;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.server.SslConnectionFactory;
import org.eclipse.jetty.util.ssl.SslContextFactory;

/**
 * Based on
 * 
 * http://stackoverflow.com/questions/14362245/programatically-configure-ssl-for-jetty-9-embedded
 * 
 * @author danidemi
 */
public class Main1 {

	public static void main(String[] args) throws Exception {
		final Server server = new Server();

		SslContextFactory contextFactory = new SslContextFactory();
		String sysout = new File("./secrets/keystore").getAbsolutePath();
		System.out.println( sysout );
		contextFactory.setKeyStorePath( sysout );
		contextFactory.setKeyStorePassword("pazzword");
		SslConnectionFactory sslConnectionFactory = new SslConnectionFactory(contextFactory, org.eclipse.jetty.http.HttpVersion.HTTP_1_1.toString());

		HttpConfiguration config = new HttpConfiguration();
		config.setSecureScheme("https");
		config.setSecurePort(8443);
		config.setOutputBufferSize(32786);
		config.setRequestHeaderSize(8192);
		config.setResponseHeaderSize(8192);
		
		HttpConfiguration sslConfiguration = new HttpConfiguration(config);
		sslConfiguration.addCustomizer(new SecureRequestCustomizer());
		HttpConnectionFactory httpConnectionFactory = new HttpConnectionFactory(sslConfiguration);

		ServerConnector connector = new ServerConnector(server, sslConnectionFactory, httpConnectionFactory);
		connector.setPort(8443);
		server.addConnector(connector);

		server.start();
		server.join();
		
		
	}
	
}
