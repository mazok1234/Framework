package mg.itu.myframework.controller;

import java.io.*;
import jakarta.servlet.*;
import java.util.*;
import jakarta.servlet.http.*;
import mg.itu.myframework.util.Util;
import mg.itu.myframework.annotation.Controller;

@Controller
public class FrontControllerServlet extends HttpServlet {
    private List<String> listController = new ArrayList<>();

    // init
    public void init() throws ServletException {
        List<String> packageNames = new ArrayList<>();
        packageNames.add("mg.itu.myframework.controller");
        packageNames.add("controller");

        List<Class<?>> controllers = Util.getClassesAnnotation(packageNames, Controller.class);
        for (Class<?> controller : controllers) {
            listController.add(controller.getName());
        }
    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter out = res.getWriter();
        out.println(processRequest(req, res) + "<br>");
        for (String controller : listController) {
            out.println("- " + controller + "<br>");
        }
    }


    private String processRequest(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());
        return path.isEmpty() ? "/" : path;
    }

}
