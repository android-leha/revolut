package test.revolut.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.HashMap;

@SpringBootApplication
@RestController
@EnableJpaRepositories(basePackageClasses={UserRepository.class})
public class WebApplication {

    private final UserService userService;

    @Autowired
    public WebApplication(UserService userService) {
        this.userService = userService;
    }

    public static void main(String[] args) {
        SpringApplication.run(WebApplication.class, args);
    }

    @PutMapping("/hello/{name:[a-z]+}")
    void create(@PathVariable String name, @RequestParam @DateTimeFormat(pattern="yyyy-MM-dd") LocalDate dateOfBirth) {
        userService.add(name, dateOfBirth);
    }

    @GetMapping("/hello/{name:[a-z]+}")
    HashMap<String, String> view(@PathVariable String name) {
        String message;
        long daysLeft = userService.getDaysUntilBirthday(name);
        if (daysLeft == 0) {
            message = String.format("Hello %s, Happy birthday", name);
        } else {
            message = String.format("Hello %s, Your birthday is in %d day(s)", name, daysLeft);
        }
        HashMap<String, String> response = new HashMap<>();
        response.put("message", message);
        return response;
    }

    @ExceptionHandler(DateTimeException.class)
    @ResponseStatus(value = HttpStatus.BAD_REQUEST)
    public @ResponseBody String handleException(DateTimeException e) {
        return e.getMessage();
    }
}
