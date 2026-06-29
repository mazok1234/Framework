package mg.itu.myframework.controller;

import java.io.*;
import jakarta.servlet.*;
import java.util.*;
import jakarta.servlet.http.*;
import mg.itu.myframework.annotation.Controller;
import mg.itu.myframework.util.ClassUtil;
import mg.itu.myframework.util.MethodClassMapping;
import mg.itu.myframework.util.UrlMethod;

@Controller
public class FrontControllerServlet extends HttpServlet {
    private List<String> listController = new ArrayList<>();
    private Map<UrlMethod, MethodClassMapping> listUrlMapping = new HashMap<>();

    // init
    public void init() throws ServletException {
        List<String> packageNames = new ArrayList<>();
        packageNames.add("mg.itu.myframework.controller");
        packageNames.add("controller");

        List<Class<?>> controllers = ClassUtil.getClassesWithAnnotation(packageNames, listUrlMapping, Controller.class);
        for (Class<?> controller : controllers) {
            listController.add(controller.getName());
        }

    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter out = res.getWriter();
        String url = processRequest(req, res);
        out.println("URL : " + url + "<br>");
        out.println("<br>Liste des classes contrôleurs : <br>");
        for (String controller : listController) {
            out.println("- " + controller + "<br>");
        }
        out.println("<br>");
        getUrlMapping(url, out, req);
    }

    public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter out = res.getWriter();
        String url = processRequest(req, res);
        out.println("URL : " + url + "<br>");
        out.println("<br>Liste des classes contrôleurs : <br>");
        for (String controller : listController) {
            out.println("- " + controller + "<br>");
        }
        out.println("<br>");
        getUrlMapping(url, out, req);
    }

    private String processRequest(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String url = req.getRequestURL().toString();
        String[] urlParts = url.split("/");
        String path = "";
        for (int i = 4 ; i < urlParts.length; i++) {
            path += "/" + urlParts[i];
        }
        
        return path;
        
    }

    private boolean isUrlAccessible(String urlName , String method) {
        for (UrlMethod url : listUrlMapping.keySet()) {
            if (url.getUrl().equals(urlName) && url.getMethod().equals(method)) {
                return true;
            }
        }
        return false;
    }

    private void invokeMethod(MethodClassMapping mapping) {
        try {
            Object instance = mapping.getClasse().getDeclaredConstructor().newInstance();
            mapping.getMethode().invoke(instance);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void getUrlMapping(String urlName , PrintWriter out , HttpServletRequest req) {
        String method = req.getMethod();
        boolean accessible = isUrlAccessible(urlName , method);
        boolean isBreak = false;

        if(!accessible){
            out.println("L'URL n'est pas accessible , voici la liste des URL accessibles : <br>");
        }
        out.println("<table border='1'>");
        out.println("<tr><th>URL</th><th>Classe</th><th>Méthode</th></tr>");
        for (UrlMethod url : listUrlMapping.keySet()) {
            MethodClassMapping mapping = listUrlMapping.get(url);
            if (mapping != null) {
                if(accessible) {
                    invokeMethod(mapping);
                    if (url.getUrl().equals(urlName) && url.getMethod().equals(method)) {
                        out.println("<tr><td>" + url.getUrl() + " (" + url.getMethod() + ")</td><td>");
                        out.println(mapping.getClasse().getName() + "</td><td>");
                        out.println(mapping.getMethode().getName() + "</td></tr>");
                        isBreak = true;
                        break;
                    }
                } else {
                    out.println("<tr><td>" + url.getUrl() + " (" + url.getMethod() + ")</td><td>");
                    out.println(mapping.getClasse().getName() + "</td><td>");
                    out.println(mapping.getMethode().getName() + "</td></tr>");
                }
            }
            if (isBreak) {
                break;
            }
        }
        if(listUrlMapping.size() == 0){
            out.println("<tr><td colspan=\"3\">Aucune URL a été trouvée</td></tr>");
        }
    }

}