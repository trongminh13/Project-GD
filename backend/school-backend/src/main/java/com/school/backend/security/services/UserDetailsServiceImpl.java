package com.school.backend.security.services;

import com.school.backend.entity.Parent;
import com.school.backend.entity.User;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {
    @Autowired
    UserRepository userRepository;

    @Autowired
    ParentRepository parentRepository;

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .or(() -> parentRepository.findByPhone(username).map(Parent::getUser))
                .orElseThrow(() -> new UsernameNotFoundException("User Not Found with username or phone: " + username));

        return UserDetailsImpl.build(user);
    }
}
